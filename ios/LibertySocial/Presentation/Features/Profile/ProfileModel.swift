//
//  ProfileModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-25.
//

import Foundation

struct ProfilePost: Decodable {
    let id: String
    let content: String?
    let media: String?
    let orientation: String?
    let createdAt: String
    let visibility: String
    let groupId: String?
    let userId: String
}

struct UserProfile: Decodable {
    let id: String
    let firstName: String
    let lastName: String
    let username: String
    let profilePhoto: String?
    let about: String?
    let gender: String?
    let isPrivate: Bool
    let connectionStatus: String?
    let requestType: String?
    let posts: [ProfilePost]?
}

struct ProfileModel {
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    /// Fetch a specific user's profile - AuthService handles token
    func fetchUserProfile(userId: String) async throws -> UserProfile {
        return try await authService.fetchUserProfile(userId: userId)
    }
}
