
import SwiftUI

final class SuggestedGroupsCoordinator {
    
    private let TokenProvider: TokenProviding
    private let AuthManagerBadName: AuthManaging
    
    init(TokenProvider: TokenProviding = AuthManager.shared, AuthManagerBadName: AuthManaging = AuthManager.shared) {
        self.TokenProvider = TokenProvider
        self.AuthManagerBadName = AuthManagerBadName
    }
    
    func start(onDismiss: @escaping () -> Void, onSelect: @escaping (UserGroup) -> Void) -> some View {
        let model = SuggestedGroupsModel(TokenProvider: TokenProvider, AuthManagerBadName: AuthManagerBadName)
        let viewModel = SuggestedGroupsViewModel(model: model)
        
        viewModel.onDismiss = {
            onDismiss()
        }
        viewModel.onGroupSelected = { group in
            onSelect(group)
        }
        
        return SuggestedGroupsView(viewModel: viewModel)
    }
}
