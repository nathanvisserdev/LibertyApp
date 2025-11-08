
import SwiftUI
import Combine

@MainActor
final class ConnectionsListCoordinator: ObservableObject {
    
    @Published var isShowingConnections: Bool = false
    @Published var isShowingProfile: Bool = false
    
    private var selectedUserId: String?
    
    private var profileCoordinator: ProfileCoordinator?
    
    private let authenticationManager: AuthManaging
    private let tokenProvider: TokenProviding

    init(authenticationManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.authenticationManager = authenticationManager
        self.tokenProvider = tokenProvider
    }
    
    
    func showConnections() {
        isShowingConnections = true
    }
    
    func showProfile(for userId: String) {
        selectedUserId = userId
        profileCoordinator = ProfileCoordinator(
            userId: userId,
            authenticationManager: authenticationManager,
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
