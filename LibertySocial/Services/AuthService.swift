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
    case unknown(Error?)
}

struct LoginResponse: Decodable {
    let accessToken: String
}

struct SignupRequest: Encodable {
    let firstName: String
    let lastName: String
    let email: String
    let username: String
    let password: String
    let dateOfBirth: String
    let gender: Bool
}

struct SignupResponse: Decodable {
    let id: String
    let email: String
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
        guard let http = response as? HTTPURLResponse else {
            throw APIError.unknown(nil)
        }

        guard (200..<300).contains(http.statusCode) else {
            let msg = String(data: respData, encoding: .utf8) ?? "Server error"
            throw APIError.server(msg)
        }

        let decoded = try JSONDecoder().decode(LoginResponse.self, from: respData)
        try? KeychainHelper.save(token: decoded.accessToken)
        return decoded.accessToken
    }

    // MARK: - Fetch /me
    static func fetchCurrentUser() async throws -> [String: Any] {
        guard let token = KeychainHelper.read() else {
            throw APIError.unauthorized
        }

        var req = URLRequest(url: baseURL.appendingPathComponent("/me"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.unauthorized
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return json ?? [:]
    }

    // MARK: - Logout
    static func logout() {
        KeychainHelper.delete()
    }
}

