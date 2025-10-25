//
//  TabBarModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-25.
//

import Foundation

struct CurrentUserInfo {
    let photoKey: String?
    let userId: String?
}

struct TabBarModel {
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    /// Fetch current user's photo and ID - AuthService handles token
    func fetchCurrentUserInfo() async throws -> CurrentUserInfo {
        let userInfo = try await authService.fetchCurrentUser()
        let photoKey = userInfo["profilePhoto"] as? String
        let userId = userInfo["id"] as? String
        return CurrentUserInfo(photoKey: photoKey, userId: userId)
    }
}
