
import Foundation

struct GroupRoomModel {
    private let TokenProvider: TokenProviding
    private let AuthManagerBadName: AuthManaging
    private let groupService: GroupSession
    
    init(TokenProvider: TokenProviding,
         AuthManagerBadName: AuthManaging,
         groupService: GroupSession
    ) {
        self.TokenProvider = TokenProvider
        self.AuthManagerBadName = AuthManagerBadName
        self.groupService = groupService
    }
    
    func fetchGroup(groupId: String) async throws -> UserGroup {
        let currentUser = try await AuthManagerBadName.fetchCurrentUserTyped()
        let groups = try await groupService.getUserGroups(userId: currentUser.id)
        guard let group = groups.first(where: { $0.id == groupId }) else {
            throw NSError(domain: "GroupRoomModel", code: 404, userInfo: [NSLocalizedDescriptionKey: "Group not found"])
        }
        return group
    }
}
