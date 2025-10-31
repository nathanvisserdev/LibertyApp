//
//  GroupModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-27.
//

import Foundation

// MARK: - Model
struct GroupModel {
    private let authSession: AuthSession
    private let authService: AuthServiceProtocol
    
    init(authSession: AuthSession = AuthService.shared, authService: AuthServiceProtocol = AuthService.shared) {
        self.authSession = authSession
        self.authService = authService
    }
    
    // Future: Add methods for fetching group details, members, posts, etc.
    // For now, this is a placeholder as GroupView is minimal
}
