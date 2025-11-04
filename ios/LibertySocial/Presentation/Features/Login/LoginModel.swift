//
//  LoginModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-25.
//

import Foundation

struct LoginResponse: Decodable { let accessToken: String }

struct LoginModel {
    private let AuthManager: AuthManaging
    
    init(AuthManager: AuthManaging = AuthService.shared) {
        self.AuthManager = AuthManager
    }
    
    /// Login user - AuthService handles token storage
    func login(email: String, password: String) async throws {
        _ = try await AuthManager.login(email: email, password: password)
    }
    
    /// Fetch current user data
    func fetchCurrentUser() async throws -> [String: Any] {
        return try await AuthManager.fetchCurrentUser()
    }
    
    /// Delete stored authentication token
    func deleteToken() {
        AuthService.shared.deleteToken()
    }
}
