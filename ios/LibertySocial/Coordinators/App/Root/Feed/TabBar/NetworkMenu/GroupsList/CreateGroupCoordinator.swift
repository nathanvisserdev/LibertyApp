import SwiftUI
import Combine

@MainActor
final class CreateGroupCoordinator {
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding
    private let groupService: GroupSession
    private let groupInviteService: GroupInviteSession
    private var childViewModels: [CreateGroupViewModel] = []
    
    var onFinish: ((String) -> Void)?
    var onCancelled: (() -> Void)?

    init(tokenProvider: TokenProviding,
         authManager: AuthManaging,
         groupService: GroupSession,
         groupInviteService: GroupInviteSession) {
        self.tokenProvider = tokenProvider
        self.authManager = authManager
        self.groupService = groupService
        self.groupInviteService = groupInviteService
    }
    
    func start(nextView: Bool = false) -> some View {
        if nextView {
            return startAdminSelectionView()
        } else {
            return startCreateGroupView()
        }
    }
    
    func handleSelectBoardMembersTap() {
        start(nextView: true)
    }
    
    func startCreateGroupView() -> AnyView {
        let model = CreateGroupModel(TokenProvider: tokenProvider, AuthManagerBadName: authManager)
        let viewModel = CreateGroupViewModel(
            model: model,
            groupService: groupService,
            inviteService: groupInviteService,
            coordinator: self
        )
        viewModel.onCancelled = { [weak self] in
            self?.onCancelled?()
        }
        viewModel.handleCreateGroupSuccess = { [weak self] groupId in
            self?.onFinish?(groupId)
        }
        viewModel.selectBoardMembersTapped = { [weak self] in
            self?.handleSelectBoardMembersTap()
        }
        childViewModels.append(viewModel)
        return AnyView(CreateGroupView(viewModel: viewModel, coordinator: self))
    }
    
    func startAdminSelectionView() -> AnyView {
        guard let viewModel = childViewModels.first else {
            return AnyView(EmptyView())
        }
        let adminSelectionView = SelectRoundTableAdminsView(viewModel: viewModel)
        return AnyView(adminSelectionView)
    }
}
