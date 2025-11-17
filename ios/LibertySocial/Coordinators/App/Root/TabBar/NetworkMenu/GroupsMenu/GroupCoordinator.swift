
import SwiftUI

final class GroupCoordinator {
    
    private let TokenProvider: TokenProviding
    private let AuthManagerBadName: AuthManaging
    private let group: UserGroup
    private let groupsListViewModel: GroupsListViewModel
    
    init(group: UserGroup,
         TokenProvider: TokenProviding,
         AuthManagerBadName: AuthManaging,
         groupsListViewModel: GroupsListViewModel) {
        self.group = group
        self.TokenProvider = TokenProvider
        self.AuthManagerBadName = AuthManagerBadName
        self.groupsListViewModel = groupsListViewModel
    }
    
    func start() -> some View {
        let model = GroupModel(TokenProvider: TokenProvider, AuthManagerBadName: AuthManagerBadName)
        let viewModel = GroupViewModel(group: group, model: model)
        
        viewModel.onClose = { [weak self] in
            self?.groupsListViewModel.hideGroup()
        }
        
        return GroupView(group: group, viewModel: viewModel)
    }
}
