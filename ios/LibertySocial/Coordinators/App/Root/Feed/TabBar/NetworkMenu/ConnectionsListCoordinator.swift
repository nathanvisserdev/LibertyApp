
import SwiftUI
import Combine

@MainActor
final class ConnectionsListCoordinator {
    private var profileCoordinator: ProfileCoordinator?
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding
    private let networkMenuViewModel: NetworkMenuViewModel

    init(authManager: AuthManaging,
         tokenProvider: TokenProviding,
         networkMenuViewModel: NetworkMenuViewModel
    ) {
        self.authManager = authManager
        self.tokenProvider = tokenProvider
        self.networkMenuViewModel = networkMenuViewModel
    }
    
    func showProfile(for userId: String) {
        profileCoordinator = ProfileCoordinator(
            userId: userId,
            authManager: authManager,
            tokenProvider: tokenProvider
        )
    }

    func start() -> some View {
        let model = ConnectionsListModel(AuthManagerBadName: authManager)
        let viewModel = ConnectionsListViewModel(
            model: model,
            onUserSelected: { [weak self] userId in
                self?.showProfile(for: userId)
            }
        )
        viewModel.makeProfileView = { [weak self] userId in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.makeProfileView())
        }
        return ConnectionsListView(viewModel: viewModel)
    }
    
    func makeProfileView() -> some View {
        guard let coordinator = profileCoordinator else {
            return AnyView(EmptyView())
        }
        return AnyView(coordinator.start())
    }
}
