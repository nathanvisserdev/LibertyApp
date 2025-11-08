
import Foundation

struct SearchUser: Decodable {
    let id: String
    let username: String
    let firstName: String
    let lastName: String
    let photo: String?
}

struct SearchGroup: Decodable {
    let id: String
    let name: String
    let groupType: String
    let isHidden: Bool
}

struct SearchResponse: Decodable {
    let users: [SearchUser]
    let groups: [SearchGroup]
}

struct SearchModel {
    private let AuthManagerBadName: AuthManaging
    
    init(AuthManagerBadName: AuthManaging = AuthManager.shared) {
        self.AuthManagerBadName = AuthManagerBadName
    }
    
    func searchUsers(query: String) async throws -> SearchResponse {
        return try await AuthManagerBadName.searchUsers(query: query)
    }
}
