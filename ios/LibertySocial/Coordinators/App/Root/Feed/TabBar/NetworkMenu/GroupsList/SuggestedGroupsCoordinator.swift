
import SwiftUI

final class SuggestedGroupsCoordinator {
    private let TokenProvider: TokenProviding
    private let AuthManagerBadName: AuthManaging
    var handleGroupTapped: ((String) -> Void)?
    
    init(TokenProvider: TokenProviding,
         AuthManagerBadName: AuthManaging) {
        self.TokenProvider = TokenProvider
        self.AuthManagerBadName = AuthManagerBadName
    }
    
    func start() -> some View {
        let model = SuggestedGroupsModel(TokenProvider: TokenProvider, AuthManagerBadName: AuthManagerBadName)
        let viewModel = SuggestedGroupsViewModel(model: model)
        
        viewModel.onGroupTapped = { [weak self] group in
            self?.handleGroupTapped?(group)
        }
        
        return SuggestedGroupsView(viewModel: viewModel)
    }
}
