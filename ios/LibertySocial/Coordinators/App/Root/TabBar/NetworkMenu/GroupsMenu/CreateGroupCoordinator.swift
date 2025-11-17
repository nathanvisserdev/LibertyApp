
import SwiftUI

@MainActor
final class CreateGroupCoordinator {
    
    private let tokenProvider: TokenProviding
    private let authManager: AuthManaging
    private let groupsListViewModel: GroupsListViewModel
    
    private var groupInviteCoordinator: GroupInviteCoordinator?
    
    private var viewModel: CreateGroupViewModel?
    
    init(tokenProvider: TokenProviding,
         authManager: AuthManaging,
         groupsListViewModel: GroupsListViewModel) {
        self.tokenProvider = tokenProvider
        self.authManager = authManager
        self.groupsListViewModel = groupsListViewModel
    }
    
    func start() -> some View {
        let model = CreateGroupModel(TokenProvider: tokenProvider, AuthManagerBadName: authManager)
        let viewModel = CreateGroupViewModel(model: model, coordinator: self)
        self.viewModel = viewModel
        
        viewModel.onFinished = { [weak self] in
            self?.groupsListViewModel.hideCreateGroupView()
        }
        viewModel.onCancelled = { [weak self] in
            self?.groupsListViewModel.hideCreateGroupView()
        }
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
