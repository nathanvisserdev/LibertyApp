
import SwiftUI
import Combine

@MainActor
final class MainMenuCoordinator: ObservableObject {
    @Published var isShowingProfile: Bool = false
    
    private var currentUserId: String?
    private var selectedUserId: String?
    private var profileCoordinator: ProfileCoordinator?
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding
    
    var onLogout: (() -> Void)?
    var onUserSelected: ((String) -> Void)?

    init(authManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.authManager = authManager
        self.tokenProvider = tokenProvider
    }
    
    func showProfile(userId: String) {
        currentUserId = userId
        isShowingProfile = true
    }
    
    func showProfile(for userId: String) {
        selectedUserId = userId
        profileCoordinator = ProfileCoordinator(
            userId: userId,
            authManager: authManager,
            tokenProvider: tokenProvider
        )
    }
    
    func openFollowers(for userId: String) {
        if profileCoordinator == nil || selectedUserId != userId {
            selectedUserId = userId
            profileCoordinator = ProfileCoordinator(
                userId: userId,
                authManager: authManager,
                tokenProvider: tokenProvider
            )
        }
        
        profileCoordinator?.openFollowers(of: userId)
    }
    
    func openFollowing(for userId: String) {
        if profileCoordinator == nil || selectedUserId != userId {
            selectedUserId = userId
            profileCoordinator = ProfileCoordinator(
                userId: userId,
                authManager: authManager,
                tokenProvider: tokenProvider
            )
        }
        
        profileCoordinator?.openFollowing(of: userId)
    }
    
    func makeView() -> some View {
        guard let userId = currentUserId else {
            return AnyView(EmptyView())
        }
        
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
