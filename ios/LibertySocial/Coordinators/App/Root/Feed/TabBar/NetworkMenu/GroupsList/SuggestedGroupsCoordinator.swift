
import SwiftUI

final class SuggestedGroupsCoordinator {
    private let TokenProvider: TokenProviding
    private let AuthManagerBadName: AuthManaging
    
    var onDismiss: (() -> Void)?
    var onGroupSelected: ((UserGroup) -> Void)?
    
    init(TokenProvider: TokenProviding,
         AuthManagerBadName: AuthManaging) {
        self.TokenProvider = TokenProvider
        self.AuthManagerBadName = AuthManagerBadName
    }
    
    func start() -> some View {
        let model = SuggestedGroupsModel(TokenProvider: TokenProvider, AuthManagerBadName: AuthManagerBadName)
        let viewModel = SuggestedGroupsViewModel(model: model)
        
        viewModel.onDismiss = { [weak self] in
            self?.onDismiss?()
        }
        viewModel.onGroupSelected = { [weak self] group in
            self?.onGroupSelected?(group)
        }
        
        return SuggestedGroupsView(viewModel: viewModel)
    }
}
