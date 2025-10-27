//
//  NotificationsModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-25.
//

import Foundation

// Unified notification item for all notification types
struct NotificationItem: Identifiable {
    let id: String
    let type: NotificationType
    let createdAt: String
    let user: NotificationUser? // User involved in the notification
    let requestType: String? // For connection requests: ACQUAINTANCE, STRANGER, IS_FOLLOWING
    let groupName: String? // For group-related notifications
    
    enum NotificationType: String {
        case connectionRequest = "connect"
        case groupInvite = "group_invite"
        case groupJoinRequest = "group_join"
    }
}

struct NotificationUser: Decodable {
    let id: String
    let firstName: String
    let lastName: String
    let username: String
    let profilePhoto: String
}

struct IncomingConnectionRequestsResponse: Decodable {
    let incomingRequests: [IncomingConnectionRequest]
}

struct IncomingConnectionRequest: Decodable {
    let id: String
    let requesterId: String
    let requestedId: String
    let type: String
    let status: String
    let createdAt: String
    let requester: NotificationUser
}

struct NotificationsModel {
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    /// Fetch all notifications (connection requests, group invites, group join requests)
    func fetchNotifications() async throws -> [NotificationItem] {
        var notifications: [NotificationItem] = []
        
        // Fetch connection requests
        let connectionRequests = try await fetchIncomingConnectionRequests()
        notifications.append(contentsOf: connectionRequests.map { req in
            NotificationItem(
                id: req.id,
                type: .connectionRequest,
                createdAt: req.createdAt,
                user: req.requester,
                requestType: req.type,
                groupName: nil
            )
        })
        
        // TODO: Add group invites and group join requests when endpoints are ready
        
        // Sort by date (newest first)
        notifications.sort { $0.createdAt > $1.createdAt }
        
        return notifications
    }
    
    /// Fetch incoming connection requests - AuthService handles token
    private func fetchIncomingConnectionRequests() async throws -> [IncomingConnectionRequest] {
        let requests = try await authService.fetchIncomingConnectionRequests()
        return requests.compactMap { req in
            guard let requester = req.requester else { return nil }
            return IncomingConnectionRequest(
                id: req.id,
                requesterId: req.requesterId,
                requestedId: req.requestedId,
                type: req.type,
                status: req.status,
                createdAt: req.createdAt,
                requester: NotificationUser(
                    id: requester.id,
                    firstName: requester.firstName,
                    lastName: requester.lastName,
                    username: requester.username,
                    profilePhoto: requester.profilePhoto
                )
            )
        }
    }
    
    /// Accept a connection request
    func acceptConnectionRequest(requestId: String) async throws {
        try await authService.acceptConnectionRequest(requestId: requestId)
    }
    
    /// Decline a connection request
    func declineConnectionRequest(requestId: String) async throws {
        try await authService.declineConnectionRequest(requestId: requestId)
    }
}
