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
    enum AuthError: Error { case noToken }

    /// Builds a URLRequest and (optionally) attaches `Authorization: Bearer <token>`
    private static func makeRequest(path: String,
                                    method: String = "GET",
                                    body: Encodable? = nil,
                                    authenticated: Bool = true) throws -> URLRequest {
        var req = URLRequest(url: baseURL.appendingPathComponent(path))
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body = body {
            req.httpBody = try JSONEncoder().encode(AnyEncodable(body))
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if authenticated {
            guard let token = KeychainHelper.read() else { throw AuthError.noToken }
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return req
    }

    /// Example of an authenticated call that uses the attached token
    struct Me: Decodable { let id: String; let email: String? }
    static func getMe() async throws -> Me {
        let req = try makeRequest(path: "/me", method: "GET", authenticated: true)
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            let msg = String(data: data, encoding: .utf8) ?? "Request failed"
            throw NSError(domain: "AuthService", code: (response as? HTTPURLResponse)?.statusCode ?? -1,
                          userInfo: [NSLocalizedDescriptionKey: msg])
        }
        return try JSONDecoder().decode(Me.self, from: data)
    }

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

// Helper to encode any Encodable without generics at the call site
private struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void
    init(_ wrapped: Encodable) { self.encodeFunc = wrapped.encode }
    func encode(to encoder: Encoder) throws { try encodeFunc(encoder) }
}


