//
//  AuthService.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-06.
//

import Foundation

struct APIUser: Decodable { let id: String; let email: String }

@MainActor
final class AuthService {
    static let baseURL = URL(string: "http://127.0.0.1:3000")!
    
    // MARK: - Availability Check
    static func checkAvailability(email: String? = nil, username: String? = nil) async throws -> Bool {
        let url = baseURL.appendingPathComponent("/availability")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let availabilityReq = AvailabilityRequest(email: email, username: username)
        req.httpBody = try JSONEncoder().encode(availabilityReq)
        
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.unknown(nil)
        }
        
        if http.statusCode == 200 {
            let decoded = try JSONDecoder().decode(AvailabilityResponse.self, from: data)
            return decoded.available
        } else {
            throw APIError.server("Failed to check availability")
        }
    }

    // MARK: - Signup
    static func signup(_ request: SignupRequest) async throws {
        let url = baseURL.appendingPathComponent("/signup")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        req.httpBody = try encoder.encode(request)
        
        // Debug: Print the request body
        if let jsonString = String(data: req.httpBody!, encoding: .utf8) {
            print("Signup request JSON:\n\(jsonString)")
        }

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.unknown(nil)
        }
        
        print("Signup response status: \(http.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("Signup response body: \(responseString)")
        }
        
        guard http.statusCode == 201 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Signup failed"
            throw APIError.server(errorMessage)
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

    // MARK: - /user/me (JSON dictionary as you had)
    static func fetchCurrentUser() async throws -> [String: Any] {
        guard let token = KeychainHelper.read() else { throw APIError.unauthorized }
        var req = URLRequest(url: baseURL.appendingPathComponent("/user/me"))
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
        var req = URLRequest(url: baseURL.appendingPathComponent("/user/me"))
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
    static func createConnectionRequest(requestedId: String, type: String) async throws -> ConnectionRequestResponse {
        guard let token = KeychainHelper.read() else { throw APIError.unauthorized }
        
        // Map IS_FOLLOWING to FOLLOW for server compatibility
        let requestType = type == "IS_FOLLOWING" ? "FOLLOW" : type
        let body = ["requestedId": requestedId, "requestType": requestType]
        let data = try JSONSerialization.data(withJSONObject: body)

        var req = URLRequest(url: baseURL.appendingPathComponent("/connections/request"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.httpBody = data

        let (respData, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let msg = String(data: respData, encoding: .utf8) ?? "Failed to create request"
            throw APIError.server(msg)
        }
        do { return try JSONDecoder().decode(ConnectionRequestResponse.self, from: respData) }
        catch { 
            print("Failed to decode response. Raw data: \(String(data: respData, encoding: .utf8) ?? "nil")")
            throw APIError.decoding 
        }
    }

    // MARK: - Search
    static func searchUsers(query: String) async throws -> SearchResponse {
        guard let token = KeychainHelper.read() else { throw APIError.unauthorized }
        
        var components = URLComponents(url: baseURL.appendingPathComponent("/search/users"), resolvingAgainstBaseURL: true)
        components?.queryItems = [URLQueryItem(name: "q", value: query)]
        
        guard let url = components?.url else { throw APIError.badURL }
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.server("Failed to search users")
        }
        
        do { return try JSONDecoder().decode(SearchResponse.self, from: data) }
        catch { throw APIError.decoding }
    }

    // MARK: - Profile
    static func fetchUserProfile(userId: String) async throws -> UserProfile {
        guard let token = KeychainHelper.read() else { throw APIError.unauthorized }
        
        var req = URLRequest(url: baseURL.appendingPathComponent("/users/\(userId)"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.server("Failed to fetch user profile")
        }
        
        do { return try JSONDecoder().decode(UserProfile.self, from: data) }
        catch { throw APIError.decoding }
    }

    // MARK: - Logout
    static func logout() { KeychainHelper.delete() }
}

