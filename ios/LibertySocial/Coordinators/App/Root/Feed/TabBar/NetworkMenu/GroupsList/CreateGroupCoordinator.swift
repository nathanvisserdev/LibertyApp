import SwiftUI
import Combine

enum NextCreateGroupView {
    case createGroup
    case adminSelection
}

@MainActor
final class CreateGroupCoordinator {
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding
    private let groupService: GroupSession
    private let groupInviteService: GroupInviteSession
    private var viewModel: [CreateGroupViewModel] = []
    var onCancelled: (() -> Void)?
    var dismissView: (() -> Void)?
    var presentNextView: ((String) -> Void)?
    var onFinish: (() -> Void)?

    init(tokenProvider: TokenProviding,
         authManager: AuthManaging,
         groupService: GroupSession,
         groupInviteService: GroupInviteSession
    ) {
        self.tokenProvider = tokenProvider
        self.authManager = authManager
        self.groupService = groupService
        self.groupInviteService = groupInviteService
    }
    
    func start(nextView: NextCreateGroupView = .createGroup) -> some View {
        switch nextView {
        case .createGroup:
            return startCreateGroupView()
        case .adminSelection:
            return startAdminSelectionView()
        }
    }
    
    func startCreateGroupView() -> AnyView {
        let model = CreateGroupModel(
            TokenProvider: tokenProvider,
            AuthManagerBadName: authManager
        )
        let viewModel = CreateGroupViewModel(
            model: model,
            groupService: groupService,
            inviteService: groupInviteService,
            coordinator: self
        )
        viewModel.presentAdminSelectionView = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(start(nextView: .adminSelection))
        }
        viewModel.onCancelled = { [weak self] in
            self?.onCancelled?()
        }
        self.viewModel.append(viewModel)
        return AnyView(CreateGroupView(viewModel: viewModel))
    }
    
    func startAdminSelectionView() -> AnyView {
        guard let viewModel = self.viewModel.first else {
            return AnyView(EmptyView())
        }
        viewModel.onCreateGroupSuccess = { [weak self] groupId in
            guard let self else { return }
            dismissView?()
            presentNextView?(groupId)
        }
        viewModel.handleDisappear = { [weak self] in
            guard let self = self else { return }
            self.viewModel.removeAll()
            self.onFinish?()
        }
        let view = AdminSelectionView(viewModel: viewModel)
        return AnyView(view)
    }
}
