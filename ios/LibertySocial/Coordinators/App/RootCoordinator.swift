
import SwiftUI
import Combine

@MainActor
final class RootCoordinator: ObservableObject {
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
        self.loginCoordinator = LoginCoordinator(
            authManager: authManager
        )
        self.rootViewModel = RootViewModel(
            isAuthenticated: initialAuthenticationState
        )
    }

    func start() -> some View {
        RootView(
            viewModel: rootViewModel,
            makeContent: { [weak self] isAuthenticated in
                guard let self = self else { return AnyView(EmptyView()) }
                if isAuthenticated {
                    return AnyView(self.tabBarCoordinator.start())
                } else {
                    return AnyView(self.loginCoordinator.start())
                }
            }
        )
    }

    func updateAuthenticationState(_ isAuthenticated: Bool) {
        rootViewModel.isAuthenticated = isAuthenticated
    }
    
    func handleDeeplink(_ url: URL) {
        print("🔗 Deeplink received in RootCoordinator: \(url)")
    }
    
    func handleNotification(_ userInfo: [AnyHashable: Any]) {
        print("🔔 Notification received in RootCoordinator: \(userInfo)")
    }
}
