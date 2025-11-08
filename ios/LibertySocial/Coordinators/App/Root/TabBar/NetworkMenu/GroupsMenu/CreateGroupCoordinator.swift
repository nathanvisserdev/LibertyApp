
import SwiftUI

@MainActor
final class CreateGroupCoordinator {
    
    private let tokenProvider: TokenProviding
    private let authManager: AuthManaging
    
    private var groupInviteCoordinator: GroupInviteCoordinator?
    
    private var viewModel: CreateGroupViewModel?
    
    init(tokenProvider: TokenProviding = AuthManager.shared, authManager: AuthManaging = AuthManager.shared) {
        self.tokenProvider = tokenProvider
        self.authManager = authManager
    }
    
    func start(onDismiss: @escaping () -> Void) -> some View {
        let model = CreateGroupModel(TokenProvider: tokenProvider, AuthManagerBadName: authManager)
        let viewModel = CreateGroupViewModel(model: model, coordinator: self)
        self.viewModel = viewModel
        
        viewModel.onFinished = onDismiss
        viewModel.onCancelled = onDismiss
        viewModel.onRequestAdminSelection = { [weak self] in
            self?.presentAdminSelection()
        }
        
        return CreateGroupViewWrapper(viewModel: viewModel, coordinator: self)
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
    
    func makeGroupInviteView(for groupId: String) -> some View {
        let coordinator = GroupInviteCoordinator(groupId: groupId)
        self.groupInviteCoordinator = coordinator
        return coordinator.start()
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
