
import SwiftUI

final class GroupDetailCoordinator {
    private let TokenProvider: TokenProviding
    private let AuthManagerBadName: AuthManaging
    private let group: UserGroup
    
    init(group: UserGroup,
         TokenProvider: TokenProviding = AuthManager.shared,
         AuthManagerBadName: AuthManaging = AuthManager.shared) {
        self.group = group
        self.TokenProvider = TokenProvider
        self.AuthManagerBadName = AuthManagerBadName
    }
    
    func start() -> some View {
        let model = GroupDetailModel(TokenProvider: TokenProvider)
        let viewModel = GroupDetailViewModel(groupId: group.id, model: model)
        return GroupDetailView(viewModel: viewModel)
    }
}
