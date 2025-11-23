
import SwiftUI

final class GroupInviteCoordinator {
    private let groupId: String
    private let tokenProvider: TokenProviding
    private let groupService: GroupSession
    private let groupInviteService: GroupInviteSession
    private var viewModel: [GroupInviteViewModel] = []
    var dismissView: (() -> Void)?
    var onFinish: (() -> Void)?
    
    init(groupId: String,
         tokenProvider: TokenProviding,
         groupService: GroupSession,
         groupInviteService: GroupInviteSession) {
        self.groupId = groupId
        self.tokenProvider = tokenProvider
        self.groupService = groupService
        self.groupInviteService = groupInviteService
    }
    
    func start() -> AnyView {
        let model = GroupInviteModel(
            TokenProvider: tokenProvider
        )
        let viewModel = GroupInviteViewModel(
            model: model,
            groupId: groupId,
            TokenProvider: tokenProvider,
            inviteService: groupInviteService,
            groupService: groupService
        )
        viewModel.onSuccess = { [weak self] in
            guard let self = self else { return }
            dismissView?()
        }
        viewModel.handleDisappear = { [weak self] in
            guard let self = self else { return }
            self.viewModel.removeAll()
            onFinish?()
        }
        self.viewModel.append(viewModel)
        return AnyView(GroupInviteView(viewModel: viewModel))
    }
}
