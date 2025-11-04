//
//  NotificationModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-25.
//

import Foundation

struct NotificationModel {
    private let AuthManager: AuthManaging
    
    init(AuthManager: AuthManaging = AuthService.shared) {
        self.AuthManager = AuthManager
    }
    
    /// Fetch incoming connection requests - AuthService handles token
    func fetchIncomingConnectionRequests() async throws -> [ConnectionRequestRow] {
        return try await AuthManager.fetchIncomingConnectionRequests()
    }
}
