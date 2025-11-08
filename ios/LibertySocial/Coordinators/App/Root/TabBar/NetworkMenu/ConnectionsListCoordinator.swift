
import SwiftUI
import Combine

@MainActor
final class ConnectionsListCoordinator: ObservableObject {
    
    @Published var isShowingConnections: Bool = false
    @Published var isShowingProfile: Bool = false
    
    private var selectedUserId: String?
    
    private var profileCoordinator: ProfileCoordinator?
    
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding

    init(authManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.authManager = authManager
        self.tokenProvider = tokenProvider
    }
    
    
    func showConnections() {
        isShowingConnections = true
    }
    
    func showProfile(for userId: String) {
        selectedUserId = userId
        profileCoordinator = ProfileCoordinator(
            userId: userId,
            authManager: authManager,
            tokenProvider: tokenProvider
        )
        isShowingProfile = true
    }

    func makeView() -> some View {
        let viewModel = ConnectionsListViewModel(
            onUserSelected: { [weak self] userId in
                self?.showProfile(for: userId)
            }
        )
        return ConnectionsListView(
            viewModel: viewModel,
            coordinator: self
        )
    }
    
    func makeProfileView() -> some View {
        guard let coordinator = profileCoordinator else {
            return AnyView(EmptyView())
        }
        return AnyView(coordinator.start())
    }
}
