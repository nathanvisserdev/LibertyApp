
import SwiftUI

final class GroupInviteCoordinator {
    private let groupId: String
    private let tokenProvider: TokenProviding
    private let groupService: GroupSession
    private let groupInviteService: GroupInviteSession
    
    init(groupId: String,
         tokenProvider: TokenProviding,
         groupService: GroupSession,
         groupInviteService: GroupInviteSession) {
        self.groupId = groupId
        self.tokenProvider = tokenProvider
        self.groupService = groupService
        self.groupInviteService = groupInviteService
    }
    
    func start() -> some View {
        let model = GroupInviteModel(TokenProvider: tokenProvider)
        let viewModel = GroupInviteViewModel(
            model: model,
            groupId: groupId,
            TokenProvider: tokenProvider,
            inviteService: groupInviteService,
            groupService: groupService
        )
        return GroupInviteView(viewModel: viewModel)
    }
}
