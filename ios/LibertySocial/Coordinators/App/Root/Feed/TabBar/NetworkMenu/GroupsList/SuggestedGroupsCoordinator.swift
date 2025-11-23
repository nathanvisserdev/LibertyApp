
import SwiftUI

@MainActor
final class SuggestedGroupsCoordinator {
    private let TokenProvider: TokenProviding
    private let AuthManagerBadName: AuthManaging
    private var viewModel: [SuggestedGroupsViewModel] = []
    var presentNextView: ((String) -> Void)?
    var dismissView: (() -> Void)?
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
            guard let self = self else { return }
            await MainActor.run {
                self.presentNextView?(groupId)
            }
        }
        viewModel.dismissView = { [weak self] in
            guard let self = self else { return }
            self.dismissView?()
        }
        viewModel.handleDisappear = { [weak self] in
            guard let self = self else { return }
            self.viewModel.removeAll()
            self.onFinish?()
        }
        self.viewModel.append(viewModel)
        return SuggestedGroupsView(viewModel: viewModel)
    }
}
