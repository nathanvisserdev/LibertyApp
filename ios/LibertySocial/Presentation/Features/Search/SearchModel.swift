//
//  SearchModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-25.
//

import Foundation

struct SearchUser: Decodable {
    let id: String
    let username: String
    let firstName: String
    let lastName: String
    let photo: String?
}

struct SearchGroup: Decodable {
    let id: String
    let name: String
    let groupType: String
    let isHidden: Bool
}

struct SearchResponse: Decodable {
    let users: [SearchUser]
    let groups: [SearchGroup]
}

struct SearchModel {
    private let AuthManager: AuthManaging
    
    init(AuthManager: AuthManaging = AuthService.shared) {
        self.AuthManager = AuthManager
    }
    
    /// Search for users and groups
    func searchUsers(query: String) async throws -> SearchResponse {
        return try await AuthManager.searchUsers(query: query)
    }
}
