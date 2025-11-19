import SwiftUI

@MainActor
final class MainMenuCoordinator {
    private var profileCoordinator: ProfileCoordinator?
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding
    
    var onLogout: (() -> Void)?

    init(authManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.authManager = authManager
        self.tokenProvider = tokenProvider
    }
    
    private func showProfile(for userId: String) {
        profileCoordinator = ProfileCoordinator(
            userId: userId,
            authManager: authManager,
            tokenProvider: tokenProvider
        )
    }
    
    func start(userId: String) -> some View {
        let model = MainMenuModel()
        let viewModel = MainMenuViewModel(
            model: model,
            userId: userId,
            onProfileTapped: { [weak self] id in
                self?.showProfile(for: id)
            }
        )
        
        viewModel.onShowProfile = { [weak self] in
            guard let self = self, let coordinator = self.profileCoordinator else {
                return AnyView(EmptyView())
            }
            return AnyView(coordinator.start())
        }
        
        return AnyView(MainMenuView(viewModel: viewModel))
    }
}
