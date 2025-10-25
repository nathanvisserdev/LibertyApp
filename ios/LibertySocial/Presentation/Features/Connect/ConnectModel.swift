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
    let username: String?
    let photo: String?
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
    /// Send a connection request to another user
    static func sendConnectionRequest(userId: String, type: String) async throws {
        _ = try await AuthService.createConnectionRequest(requestedId: userId, type: type)
    }
}
