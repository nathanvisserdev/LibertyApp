//
//  FeedModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-25.
//

import Foundation

struct FeedItem: Decodable {
    let id: String
    let userId: String
    let content: String?
    let media: String?
    let createdAt: String
    let user: UserSummary
    let relation: String
    
    struct UserSummary: Decodable {
        let id: String
        let username: String
        let firstName: String
        let lastName: String
        let profilePhoto: String
    }
}

struct FeedModel {
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    /// Fetch feed - AuthService handles token
    func fetchFeed() async throws -> [FeedItem] {
        return try await authService.fetchFeed()
    }
}
