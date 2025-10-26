//
//  ConnectModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-25.
//

import Foundation

struct ConnectionRequestResponse: Decodable {
    let requesterId: String
    let requestedId: String
    let requestType: String
}

struct RequesterUser: Decodable {
    let id: String
    let firstName: String
    let lastName: String
    let username: String
    let profilePhoto: String
}

struct ConnectionRequestRow: Decodable {
    let id: String
    let requesterId: String
    let requestedId: String
    let type: String
    let status: String
    let createdAt: String
    let requester: RequesterUser?
}

struct ConnectModel {
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    /// Send a connection request - AuthService handles token
    func sendConnectionRequest(userId: String, type: String) async throws -> ConnectionRequestResponse {
        return try await authService.createConnectionRequest(requestedId: userId, type: type)
    }
}
