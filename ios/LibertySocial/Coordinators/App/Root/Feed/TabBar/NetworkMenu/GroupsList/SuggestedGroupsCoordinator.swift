
import SwiftUI

@MainActor
final class SuggestedGroupsCoordinator {
    private let TokenProvider: TokenProviding
    private let AuthManagerBadName: AuthManaging
    var DisplayAboutGroupView: ((String) -> Void)?
    var onFinish: (() -> Void)?
    
    init(TokenProvider: TokenProviding,
         AuthManagerBadName: AuthManaging) {
        self.TokenProvider = TokenProvider
        self.AuthManagerBadName = AuthManagerBadName
    }
    
    func start() -> some View {
        let model = SuggestedGroupsModel(
            TokenProvider: TokenProvider,
            AuthManagerBadName: AuthManagerBadName
        )
        let viewModel = SuggestedGroupsViewModel(model: model)
        viewModel.handleGroupTap = { [weak self] groupId in
            self?.onFinish?()
            self?.DisplayAboutGroupView?(groupId)
        }
        return SuggestedGroupsView(viewModel: viewModel)
    }
}
