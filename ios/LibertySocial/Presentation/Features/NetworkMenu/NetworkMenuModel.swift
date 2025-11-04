//
//  NetworkMenuModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-26.
//

import Foundation

// MARK: - User Group Response
struct UserGroupsResponse: Codable {
    let groups: [UserGroup]
}

struct UserGroup: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let groupType: String
    let isHidden: Bool
    let adminId: String
    let admin: GroupAdmin
    let displayLabel: String
    let joinedAt: Date
}

struct GroupAdmin: Codable {
    let id: String
    let username: String
    let firstName: String?
    let lastName: String?
}

// MARK: - Model
struct NetworkMenuModel {
    private let AuthManager: AuthManaging
    
    init(AuthManager: AuthManaging = AuthService.shared) {
        self.AuthManager = AuthManager
    }
}
