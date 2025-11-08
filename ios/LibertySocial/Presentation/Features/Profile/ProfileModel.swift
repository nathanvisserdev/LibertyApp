
import Foundation

struct ProfilePost: Decodable, Identifiable {
    let postId: String
    let content: String?
    let media: String?
    let orientation: String?
    let createdAt: String
    let visibility: String
    let groupId: String?
    let userId: String
    
    var id: String { postId } // Identifiable conformance
}

struct UserProfile: Decodable {
    let id: String
    let firstName: String
    let lastName: String
    let username: String
    let profilePhoto: String?
    let about: String?
    let gender: String?
    let isPrivate: Bool
    let connectionStatus: String?
    let requestType: String?
    let followerCount: Int?
    let followingCount: Int?
    let isFollowingYou: Bool?
    let posts: [ProfilePost]?
}

struct ProfileModel {
    private let AuthManagerBadName: AuthManaging
    
    init(AuthManagerBadName: AuthManaging = AuthManager.shared) {
        self.AuthManagerBadName = AuthManagerBadName
    }
    
    func fetchUserProfile(userId: String) async throws -> UserProfile {
        return try await AuthManagerBadName.fetchUserProfile(userId: userId)
    }
}
