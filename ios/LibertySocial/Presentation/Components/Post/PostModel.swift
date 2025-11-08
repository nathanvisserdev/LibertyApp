
import Foundation

struct PostItem: Decodable, Identifiable {
    let postId: String
    let userId: String
    let content: String?
    let media: String?
    let orientation: String?
    let createdAt: String
    let user: UserSummary
    
    var id: String { postId } // Identifiable conformance
    
    struct UserSummary: Decodable {
        let id: String
        let username: String
        let firstName: String
        let lastName: String
        let profilePhoto: String
    }
}

extension PostItem {
    init(from feedItem: FeedItem) {
        self.postId = feedItem.postId
        self.userId = feedItem.userId
        self.content = feedItem.content
        self.media = feedItem.media
        self.orientation = feedItem.orientation
        self.createdAt = feedItem.createdAt
        self.user = UserSummary(
            id: feedItem.user.id,
            username: feedItem.user.username,
            firstName: feedItem.user.firstName,
            lastName: feedItem.user.lastName,
            profilePhoto: feedItem.user.profilePhoto
        )
    }
}
