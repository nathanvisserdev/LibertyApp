
import Foundation

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

struct NetworkMenuModel {
    private let AuthManagerBadName: AuthManaging
    
    init(AuthManagerBadName: AuthManaging) {
        self.AuthManagerBadName = AuthManagerBadName
    }
}
