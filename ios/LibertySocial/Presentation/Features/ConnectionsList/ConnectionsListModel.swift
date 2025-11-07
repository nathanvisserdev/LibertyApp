//
//  ConnectionsListModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-26.
//

import Foundation

struct Connection: Decodable, Identifiable {
    let id: String
    let userId: String
    let firstName: String
    let lastName: String
    let username: String
    let profilePhoto: String?
    let type: String
    let createdAt: String
}

struct ConnectionsListModel {
    private let AuthManager: AuthManaging
    
    init(AuthManager: AuthManaging = AuthService.shared) {
        self.AuthManager = AuthManager
    }
    
    /// Fetch connections - AuthService handles token
    func fetchConnections() async throws -> [Connection] {
        return try await AuthManager.fetchConnections()
    }
}
