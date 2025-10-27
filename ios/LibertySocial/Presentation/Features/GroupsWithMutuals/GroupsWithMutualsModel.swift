//
//  GroupsWithMutualsModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-27.
//

import Foundation

// MARK: - API
struct GroupsWithMutualsModel {
    static func fetchJoinableGroups(userId: String) async throws -> [UserGroup] {
        // Reuse the existing NetworkModel function since it calls the same endpoint
        return try await NetworkModel.fetchUserGroups(userId: userId)
    }
}
