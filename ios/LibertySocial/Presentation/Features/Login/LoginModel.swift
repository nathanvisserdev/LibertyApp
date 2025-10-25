//
//  LoginModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-25.
//

import Foundation

struct LoginResponse: Decodable { let accessToken: String }

struct LoginModel {
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    /// Login user - AuthService handles token storage
    func login(email: String, password: String) async throws {
        _ = try await authService.login(email: email, password: password)
    }
}
