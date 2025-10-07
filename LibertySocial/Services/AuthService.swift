//
//  AuthService.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-06.
//

import Foundation

struct AuthResponse: Decodable { let accessToken: String }

struct AuthService {
    static let baseURL = URL(string: "http://127.0.0.1:3000")!

    static func signup(email: String, password: String) async throws {
        var req = URLRequest(url: baseURL.appendingPathComponent("/signup"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(["email": email, "password": password])

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 201 else {
            let msg = String(data: data, encoding: .utf8) ?? "Signup failed"
            throw NSError(domain: "AuthService", code: (response as? HTTPURLResponse)?.statusCode ?? -1,
                          userInfo: [NSLocalizedDescriptionKey: msg])
        }
        print("✅ Signup success")
    }

    static func login(email: String, password: String) async throws -> String {
        var req = URLRequest(url: baseURL.appendingPathComponent("/login"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(["email": email, "password": password])

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let msg = String(data: data, encoding: .utf8) ?? "Login failed"
            throw NSError(domain: "AuthService", code: (response as? HTTPURLResponse)?.statusCode ?? -1,
                          userInfo: [NSLocalizedDescriptionKey: msg])
        }
        let auth = try JSONDecoder().decode(AuthResponse.self, from: data)
        print("✅ Login success, token:", auth.accessToken)
        return auth.accessToken
    }
}


