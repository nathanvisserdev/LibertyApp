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
    private let AuthManager: AuthManaging
    init(AuthManager: AuthManaging) {
        self.AuthManager = AuthManager
    }
    
    /// Fetch current user's photo and ID - AuthService handles token
    func fetchCurrentUserInfo() async throws -> CurrentUserInfo {
        let userInfo = try await AuthManager.fetchCurrentUser()
        let photoKey = userInfo["profilePhoto"] as? String
        let userId = userInfo["id"] as? String
        return CurrentUserInfo(photoKey: photoKey, userId: userId)
    }
}
