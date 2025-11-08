
import SwiftUI
import Combine

@MainActor
final class RootCoordinator: ObservableObject {
    private let signupCoordinator: SignupCoordinator
    private let loginCoordinator: LoginCoordinator
    private let tabBarCoordinator: TabBarCoordinator
    
    @Published private var rootViewModel: RootViewModel

    init(
        initialAuthenticationState: Bool,
        authManager: AuthManaging,
        tokenProvider: TokenProviding,
        feedService: FeedSession,
        commentService: CommentService
    ) {
        self.tabBarCoordinator = TabBarCoordinator(
            authManager: authManager,
            tokenProvider: tokenProvider,
            feedService: feedService,
            commentService: commentService
        )
        self.loginCoordinator = LoginCoordinator()
        self.signupCoordinator = SignupCoordinator()
        self.rootViewModel = RootViewModel(
            model: RootModel(),
            isAuthenticated: initialAuthenticationState
        )
        
        self.rootViewModel.onAuthenticationInvalidated = { [weak self] in
            self?.handleAuthenticationInvalidated()
        }
        
        self.rootViewModel.onShowAuthenticatedContent = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.tabBarCoordinator.start())
        }
        
        self.rootViewModel.onShowLoginContent = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.loginCoordinator.start())
        }
    }

    func start() -> some View {
        return RootView(viewModel: rootViewModel)
    }
    
    func updateAuthenticationState(_ isAuthenticated: Bool) {
        rootViewModel.isAuthenticated = isAuthenticated
    }
    
    private func handleAuthenticationInvalidated() {
        print("🔓 Authentication invalidated - routing to login flow")
    }
    
    func handleDeeplink(_ url: URL) {
        print("🔗 Deeplink received in RootCoordinator: \(url)")
    }
    
    func handleNotification(_ userInfo: [AnyHashable: Any]) {
        print("🔔 Notification received in RootCoordinator: \(userInfo)")
    }
}
