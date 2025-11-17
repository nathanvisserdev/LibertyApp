
import SwiftUI

final class SuggestedGroupsCoordinator {
    
    private let TokenProvider: TokenProviding
    private let AuthManagerBadName: AuthManaging
    private let groupsListViewModel: GroupsListViewModel
    
    init(TokenProvider: TokenProviding,
         AuthManagerBadName: AuthManaging,
         groupsListViewModel: GroupsListViewModel) {
        self.TokenProvider = TokenProvider
        self.AuthManagerBadName = AuthManagerBadName
        self.groupsListViewModel = groupsListViewModel
    }
    
    func start() -> some View {
        let model = SuggestedGroupsModel(TokenProvider: TokenProvider, AuthManagerBadName: AuthManagerBadName)
        let viewModel = SuggestedGroupsViewModel(model: model)
        
        viewModel.onDismiss = { [weak self] in
            self?.groupsListViewModel.hideSuggestedGroupsView()
        }
        viewModel.onGroupSelected = { [weak self] group in
            self?.groupsListViewModel.hideSuggestedGroupsView()
            self?.groupsListViewModel.showGroup(group)
        }
        
        return SuggestedGroupsView(viewModel: viewModel)
    }
}
