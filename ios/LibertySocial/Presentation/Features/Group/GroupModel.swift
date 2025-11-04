//
//  GroupModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-27.
//

import Foundation

// MARK: - Model
struct GroupModel {
    private let TokenProvider: TokenProviding
    private let AuthManager: AuthManaging
    
    init(TokenProvider: TokenProviding = AuthService.shared, AuthManager: AuthManaging = AuthService.shared) {
        self.TokenProvider = TokenProvider
        self.AuthManager = AuthManager
    }
    
    // Future: Add methods for fetching group details, members, posts, etc.
    // For now, this is a placeholder as GroupView is minimal
}
