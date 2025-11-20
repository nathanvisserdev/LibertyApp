
import Foundation

struct GroupDetail: Codable {
    let groupId: String
    let name: String
    let description: String?
    let groupType: String
    let groupPrivacy: String
    let isHidden: Bool
    let admin: GroupDetailAdmin
    let memberCount: Int
    let members: [GroupMember]
    let memberVisibility: String
    let isMember: Bool
    let isAdmin: Bool
    
    enum CodingKeys: String, CodingKey {
        case groupId = "id"
        case name
        case description
        case groupType
        case groupPrivacy
        case isHidden
        case admin
        case memberCount
        case members
        case memberVisibility
        case isMember
        case isAdmin
    }
}

struct GroupDetailAdmin: Codable {
    let userId: String
    let firstName: String?
    let lastName: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "id"
        case firstName
        case lastName
    }
}

struct GroupMember: Codable, Identifiable {
    let groupMembershipId: String
    let userId: String
    let joinedAt: Date
    let isBanned: Bool
    let groupId: String
    let user: MemberUser
    
    var id: String { groupMembershipId }
    
    enum CodingKeys: String, CodingKey {
        case groupMembershipId = "membershipId"
        case userId
        case joinedAt
        case isBanned
        case groupId
        case user
    }
}

struct MemberUser: Codable {
    let userId: String
    let firstName: String?
    let lastName: String?
    let username: String?
    let profilePhoto: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "id"
        case firstName
        case lastName
        case username
        case profilePhoto
    }
}

struct AboutGroupModel {
    
    private let groupService: GroupSession
    
    init(groupService: GroupSession) {
        self.groupService = groupService
    }
    
    func fetchGroupDetail(groupId: String) async throws -> GroupDetail {
        return try await groupService.fetchGroupDetail(groupId: groupId)
    }
    
    func joinGroup(groupId: String) async throws {
        try await groupService.joinGroup(groupId: groupId)
    }
}
