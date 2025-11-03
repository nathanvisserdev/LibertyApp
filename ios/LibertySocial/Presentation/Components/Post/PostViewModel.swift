//
//  PostViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-11-03.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class PostViewModel: ObservableObject {
    // MARK: - Properties
    let post: PostItem
    let currentUserId: String?
    let showMenu: Bool
    
    // MARK: - Init
    init(post: PostItem, currentUserId: String? = nil, showMenu: Bool = true) {
        self.post = post
        self.currentUserId = currentUserId
        self.showMenu = showMenu
    }
    
    // MARK: - Computed Properties
    var isCurrentUsersPost: Bool {
        guard let currentUserId = currentUserId else { return false }
        return post.userId == currentUserId
    }
    
    var authorDisplayName: String {
        "\(post.user.firstName) \(post.user.lastName)"
    }
    
    var authorUsername: String {
        "@\(post.user.username)"
    }
    
    var formattedDate: String {
        DateFormatter.feed.string(fromISO: post.createdAt)
    }
}
