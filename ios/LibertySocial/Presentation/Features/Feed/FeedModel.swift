
import Foundation

struct FeedItem: Decodable, Identifiable {
    let postId: String
    let userId: String
    let content: String?
    let media: String?
    let orientation: String?
    let createdAt: String
    let user: UserSummary
    let relation: String
    
    var id: String { postId } // Identifiable conformance
    
    struct UserSummary: Decodable {
        let id: String
        let username: String
        let firstName: String
        let lastName: String
        let profilePhoto: String
    }
}

struct FeedModel {
    private let AuthManagerBadName: AuthManaging
    init(AuthManagerBadName: AuthManaging) {
        self.AuthManagerBadName = AuthManagerBadName
    }
    
    func fetchFeed() async throws -> [FeedItem] {
        return try await AuthManagerBadName.fetchFeed()
    }
}
