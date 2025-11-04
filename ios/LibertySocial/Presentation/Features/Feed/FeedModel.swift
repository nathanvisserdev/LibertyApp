//
//  FeedModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-25.
//

import Foundation

struct FeedItem: Decodable, Identifiable {
    let postId: String
    let userId: String
    let content: String?
    let media: String?
    let orientation: String?
    let createdAt: String
    let user: UserSummary
    let relation: String
    
    var id: String { postId } // Identifiable conformance
    
    struct UserSummary: Decodable {
        let id: String
        let username: String
        let firstName: String
        let lastName: String
        let profilePhoto: String
    }
}

struct FeedModel {
    private let AuthManager: AuthManaging
    
    init(AuthManager: AuthManaging = AuthService.shared) {
        self.AuthManager = AuthManager
    }
    
    /// Fetch feed - AuthService handles token
    func fetchFeed() async throws -> [FeedItem] {
        return try await AuthManager.fetchFeed()
    }
}
