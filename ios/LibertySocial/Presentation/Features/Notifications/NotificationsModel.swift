//
//  NotificationsModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-25.
//

import Foundation

struct NotificationsModel {
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    /// Fetch incoming connection requests - AuthService handles token
    func fetchIncomingConnectionRequests() async throws -> [ConnectionRequestRow] {
        return try await authService.fetchIncomingConnectionRequests()
    }
}
