
import Foundation
import SwiftUI
import Combine

@MainActor
final class PostViewModel: ObservableObject {
    let post: PostItem
    let currentUserId: String?
    let showMenu: Bool
    
    init(post: PostItem, currentUserId: String? = nil, showMenu: Bool = true) {
        self.post = post
        self.currentUserId = currentUserId
        self.showMenu = showMenu
    }
    
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
        DateFormatters.string(fromISO: post.createdAt)
    }
}
