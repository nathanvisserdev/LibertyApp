//
//  AuthService.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-06.
//

import Foundation

enum APIError: Error {
    case badURL
    case server(String)
    case unauthorized
    case decoding
    case unknown(Error?)
}

// MARK: - Models
struct LoginResponse: Decodable { let accessToken: String }

struct SignupRequest: Encodable {
    // NOTE: server currently expects only email/password; keep this if you still use it elsewhere.
    let firstName: String
    let lastName: String
    let email: String
    let username: String
    let password: String
    let dateOfBirth: String
    let gender: Bool
}

struct SignupResponse: Decodable { let id: String; let email: String }

struct APIUser: Decodable { let id: String; let email: String }

struct FeedItem: Decodable {
    let id: String
    let userId: String
    let content: String
    let createdAt: String
    let user: UserSummary
    let relation: String
    struct UserSummary: Decodable { let id: String; let email: String }
}

struct ConnectionRequestRow: Decodable {
    let id: String
    let requesterId: String
    let requestedId: String
    let type: String
    let status: String
    let createdAt: String
    let requester: APIUser?
}

@MainActor
final class AuthService {
    static let baseURL = URL(string: "http://127.0.0.1:3000")!

    // MARK: - Signup
    static func signup(_ request: SignupRequest) async throws {
        let url = baseURL.appendingPathComponent("/signup")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(request)

        let (_, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 201 else {
            throw APIError.server("Signup failed")
        }
    }

    // MARK: - Login
    static func login(email: String, password: String) async throws -> String {
        let payload = ["email": email, "password": password]
        let data = try JSONSerialization.data(withJSONObject: payload)
        var req = URLRequest(url: baseURL.appendingPathComponent("/login"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = data

        let (respData, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw APIError.unknown(nil) }
        guard (200..<300).contains(http.statusCode) else {
            let msg = String(data: respData, encoding: .utf8) ?? "Server error"
            throw APIError.server(msg)
        }

        let decoded = try JSONDecoder().decode(LoginResponse.self, from: respData)
        try? KeychainHelper.save(token: decoded.accessToken)
        return decoded.accessToken
    }

    // MARK: - /user (JSON dictionary as you had)
    static func fetchCurrentUser() async throws -> [String: Any] {
        guard let token = KeychainHelper.read() else { throw APIError.unauthorized }
        var req = URLRequest(url: baseURL.appendingPathComponent("/user"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.unauthorized
        }
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return json ?? [:]
    }

    // Optional typed variant if you want it:
    static func fetchCurrentUserTyped() async throws -> APIUser {
        guard let token = KeychainHelper.read() else { throw APIError.unauthorized }
        var req = URLRequest(url: baseURL.appendingPathComponent("/user"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { throw APIError.unauthorized }
        do { return try JSONDecoder().decode(APIUser.self, from: data) }
        catch { throw APIError.decoding }
    }

    // MARK: - Feed
    static func fetchFeed() async throws -> [FeedItem] {
        guard let token = KeychainHelper.read() else { throw APIError.unauthorized }
        var req = URLRequest(url: baseURL.appendingPathComponent("/feed"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.server("Failed to load feed")
        }
        do { return try JSONDecoder().decode([FeedItem].self, from: data) }
        catch { throw APIError.decoding }
    }

    // MARK: - Connections (incoming requests)
    static func fetchIncomingConnectionRequests() async throws -> [ConnectionRequestRow] {
        guard let token = KeychainHelper.read() else { throw APIError.unauthorized }
        var req = URLRequest(url: baseURL.appendingPathComponent("/connections/requests/incoming"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.server("Failed to load incoming requests")
        }
        do { return try JSONDecoder().decode([ConnectionRequestRow].self, from: data) }
        catch { throw APIError.decoding }
    }

    // Create a connection request
    static func createConnectionRequest(requestedId: String, type: String) async throws -> ConnectionRequestRow {
        guard let token = KeychainHelper.read() else { throw APIError.unauthorized }
        let body = ["requestedId": requestedId, "type": type]
        let data = try JSONSerialization.data(withJSONObject: body)

        var req = URLRequest(url: baseURL.appendingPathComponent("/connections/requests"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.httpBody = data

        let (respData, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let msg = String(data: respData, encoding: .utf8) ?? "Failed to create request"
            throw APIError.server(msg)
        }
        do { return try JSONDecoder().decode(ConnectionRequestRow.self, from: respData) }
        catch { throw APIError.decoding }
    }

    // MARK: - Logout
    static func logout() { KeychainHelper.delete() }
}

