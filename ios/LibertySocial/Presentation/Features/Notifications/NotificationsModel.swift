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
    let groupId: String? // For group-related notifications
    
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

struct GroupJoinRequest: Decodable {
    let id: String
    let requesterId: String
    let groupId: String
    let status: String
    let createdAt: String
    let requester: GroupJoinRequester
}

struct GroupJoinRequester: Decodable {
    let id: String
    let username: String
    let firstName: String?
    let lastName: String?
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
                groupName: nil,
                groupId: nil
            )
        })
        
        // Fetch group join requests
        let groupJoinRequests = try await fetchGroupJoinRequests()
        notifications.append(contentsOf: groupJoinRequests)
        
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
    
    /// Fetch group join requests for all groups where user is a moderator
    private func fetchGroupJoinRequests() async throws -> [NotificationItem] {
        var notifications: [NotificationItem] = []
        
        // First, get all groups where the current user is a member
        guard let currentUser = try? await authService.fetchCurrentUserTyped() else {
            return []
        }
        
        // Fetch user's groups
        guard let url = URL(string: "\(AppConfig.baseURL)/users/\(currentUser.id)/groups") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = KeychainHelper.read() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            return []
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        struct UserGroupsResponse: Decodable {
            let groups: [UserGroupInfo]
        }
        
        struct UserGroupInfo: Decodable {
            let id: String
            let name: String
            let adminId: String
        }
        
        let groupsResponse = try decoder.decode(UserGroupsResponse.self, from: data)
        
        print("📦 Found \(groupsResponse.groups.count) total groups")
        
        // For each group where user is admin or moderator, try to fetch pending join requests
        for group in groupsResponse.groups {
            print("🔍 Checking group: \(group.name) (id: \(group.id), adminId: \(group.adminId))")
            print("   User is admin: \(group.adminId == currentUser.id)")
            
            // The endpoint will return 403 if user is not a moderator, so we just try for all groups
            // Groups where user is admin will automatically be included since they have moderator access
            if let groupRequests = try? await fetchPendingJoinRequestsForGroup(groupId: group.id, groupName: group.name) {
                print("   ✅ Found \(groupRequests.count) pending join requests for \(group.name)")
                notifications.append(contentsOf: groupRequests)
            } else {
                print("   ❌ No join requests or not authorized for \(group.name)")
            }
        }
        
        print("📊 Total group join request notifications: \(notifications.count)")
        
        return notifications
    }
    
    /// Fetch pending join requests for a specific group
    private func fetchPendingJoinRequestsForGroup(groupId: String, groupName: String) async throws -> [NotificationItem] {
        guard let url = URL(string: "\(AppConfig.baseURL)/groups/\(groupId)/join-requests/pending") else {
            throw URLError(.badURL)
        }
        
        print("   🌐 Calling: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = KeychainHelper.read() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("   📡 Response status: \(httpResponse.statusCode)")
        
        // If 403 or 404, user is not a moderator for this group, skip it
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 403 {
                print("   🚫 403 Forbidden - User is not a moderator for this group")
            } else if httpResponse.statusCode == 404 {
                print("   🚫 404 Not Found")
            }
            return []
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let requests = try decoder.decode([GroupJoinRequest].self, from: data)
        
        print("   📥 Decoded \(requests.count) join requests")
        
        return requests.map { req in
            NotificationItem(
                id: req.id,
                type: .groupJoinRequest,
                createdAt: req.createdAt,
                user: NotificationUser(
                    id: req.requester.id,
                    firstName: req.requester.firstName ?? "",
                    lastName: req.requester.lastName ?? "",
                    username: req.requester.username,
                    profilePhoto: ""
                ),
                requestType: nil,
                groupName: groupName,
                groupId: groupId
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
    
    /// Accept a group join request
    func acceptGroupJoinRequest(requestId: String) async throws {
        guard let url = URL(string: "\(AppConfig.baseURL)/groups/requests/\(requestId)/accept") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = KeychainHelper.read() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data)["error"]) ?? "Failed to accept group join request"
            throw NSError(domain: "NotificationsModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
    
    /// Decline a group join request
    func declineGroupJoinRequest(requestId: String) async throws {
        guard let url = URL(string: "\(AppConfig.baseURL)/groups/requests/\(requestId)/decline") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = KeychainHelper.read() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data)["error"]) ?? "Failed to decline group join request"
            throw NSError(domain: "NotificationsModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
}
