/*
#if DEBUG
import Foundation

final class StubAuth: AuthManaging {
    var currentUserId: String? = "stub-user-id"
    var currentUser: APIUser? = APIUser(
        id: "stub-user-id",
        email: "stub@example.com",
        username: "stubuser",
        fullname: "Stub User",
        bio: nil,
        photoKey: nil,
        isPrivate: false,
        createdAt: "2025-01-01T00:00:00Z"
    )
    
    func getAuthToken() async throws -> String {
        return "stub-token"
    }
    
    func getCurrentUserIsPrivate() async throws -> Bool {
        return false
    }
    
    func login(email: String, password: String) async throws -> LoginResponse {
        return LoginResponse(accessToken: "stub-token", userId: "stub-user-id")
    }
    
    func signup(email: String, password: String, username: String, fullname: String) async throws -> LoginResponse {
        return LoginResponse(accessToken: "stub-token", userId: "stub-user-id")
    }
    
    func logout() {
    }
    
    func deleteToken() {
    }
    
    func fetchCurrentUser() async throws -> APICurrentUser {
        return APICurrentUser(
            id: "stub-user-id",
            email: "stub@example.com",
            username: "stubuser",
            fullname: "Stub User",
            bio: nil,
            photoKey: nil,
            isPrivate: false,
            createdAt: "2025-01-01T00:00:00Z",
            deviceTokens: []
        )
    }
    
    func fetchUserProfile(userId: String) async throws -> UserProfile {
        return UserProfile(
            id: userId,
            username: "stubuser",
            fullname: "Stub User",
            bio: nil,
            photoKey: nil,
            isPrivate: false,
            isFollowing: false,
            hasRequestedFollow: false,
            followerCount: 0,
            followingCount: 0
        )
    }
    
    func updateProfile(fullname: String, username: String, bio: String?) async throws {
    }
    
    func updateProfilePhoto(mediaKey: String?) async throws {
    }
    
    func followUser(userId: String) async throws {
    }
    
    func unfollowUser(userId: String) async throws {
    }
    
    func searchUsers(query: String) async throws -> SearchResponse {
        return SearchResponse(users: [], groups: [])
    }
    
    func fetchConnections() async throws -> [Connection] {
        return []
    }
    
    func fetchIncomingConnectionRequests() async throws -> [ConnectionRequestRow] {
        return []
    }
    
    func acceptConnectionRequest(requestId: String) async throws {
    }
    
    func rejectConnectionRequest(requestId: String) async throws {
    }
}
#endif
*/
