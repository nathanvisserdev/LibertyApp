//
//  ConnectModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-25.
//

import Foundation

struct ConnectModel {
    /// Send a connection request to another user
    static func sendConnectionRequest(userId: String, type: String) async throws {
        _ = try await AuthService.createConnectionRequest(requestedId: userId, type: type)
    }
}
