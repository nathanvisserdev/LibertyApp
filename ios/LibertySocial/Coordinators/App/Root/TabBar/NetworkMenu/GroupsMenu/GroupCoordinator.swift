
import SwiftUI

final class GroupCoordinator {
    
    private let TokenProvider: TokenProviding
    private let AuthManagerBadName: AuthManaging
    private let group: UserGroup
    
    init(group: UserGroup, TokenProvider: TokenProviding = AuthManager.shared, AuthManagerBadName: AuthManaging = AuthManager.shared) {
        self.group = group
        self.TokenProvider = TokenProvider
        self.AuthManagerBadName = AuthManagerBadName
    }
    
    func start(onClose: @escaping () -> Void) -> some View {
        let model = GroupModel(TokenProvider: TokenProvider, AuthManagerBadName: AuthManagerBadName)
        let viewModel = GroupViewModel(group: group, model: model)
        
        viewModel.onClose = {
            onClose()
        }
        
        return GroupView(group: group, viewModel: viewModel)
    }
}
