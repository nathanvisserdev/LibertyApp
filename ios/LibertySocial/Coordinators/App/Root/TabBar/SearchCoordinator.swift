import SwiftUI

@MainActor
final class SearchCoordinator {
    private var profileCoordinator: ProfileCoordinator?
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding

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

    func start() -> some View {
        let model = SearchModel(AuthManagerBadName: authManager)
        let viewModel = SearchViewModel(
            model: model,
            onUserSelected: { [weak self] userId in
                self?.showProfile(for: userId)
            }
        )
        
        viewModel.onShowProfile = { [weak self] in
            guard let self = self,
                  let coordinator = self.profileCoordinator else {
                return AnyView(EmptyView())
            }
            return AnyView(coordinator.start())
        }
        
        return SearchView(viewModel: viewModel)
    }
}
