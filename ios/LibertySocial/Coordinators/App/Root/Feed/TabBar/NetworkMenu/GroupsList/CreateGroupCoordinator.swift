
import SwiftUI

@MainActor
final class CreateGroupCoordinator {
    
    private let tokenProvider: TokenProviding
    private let authManager: AuthManaging
    private let groupService: GroupSession
    private let groupInviteService: GroupInviteSession
    
    private var viewModel: CreateGroupViewModel?
    
    var handlePresentGroupInviteView: ((String) -> Void)?
    var onFinished: (() -> Void)?
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
    
    func start(groupId: String? = nil) -> some View {
        let model = CreateGroupModel(TokenProvider: tokenProvider, AuthManagerBadName: authManager)
        let viewModel = CreateGroupViewModel(
            model: model,
            groupService: groupService,
            inviteService: groupInviteService,
            coordinator: self
        )
        self.viewModel = viewModel
        
        viewModel.onFinished = { [weak self] in
            self?.onFinished?()
        }
        viewModel.onCancelled = { [weak self] in
            self?.onCancelled?()
        }
        viewModel.onRequestAdminSelection = { [weak self] in
            self?.presentAdminSelection()
        }
        viewModel.createGroupSucceeded = { [weak self] groupId in
            self?.handleCreateGroupSuccess(for: groupId)
        }
        return CreateGroupViewWrapper(viewModel: viewModel, coordinator: self)
    }
    
    func handleCreateGroupSuccess(for groupId: String) {
        handlePresentGroupInviteView?(groupId)
    }
    
    
    func presentAdminSelection() {
        viewModel?.showAdminSelection = true
    }
    
    func dismissAdminSelection() {
        viewModel?.showAdminSelection = false
    }
    
    
    func makeAdminSelectionView() -> some View {
        guard let viewModel = viewModel else {
            return AnyView(EmptyView())
        }
        return AnyView(SelectRoundTableAdminsView(viewModel: viewModel))
    }
}


private struct CreateGroupViewWrapper: View {
    @ObservedObject var viewModel: CreateGroupViewModel
    let coordinator: CreateGroupCoordinator
    
    var body: some View {
        CreateGroupView(viewModel: viewModel, coordinator: coordinator)
            .sheet(isPresented: $viewModel.showAdminSelection) {
                coordinator.makeAdminSelectionView()
            }
    }
}
