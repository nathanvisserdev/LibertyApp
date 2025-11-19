
import SwiftUI
import Combine

@MainActor
final class RootCoordinator: ObservableObject {
    private let loginCoordinator: LoginCoordinator
    private let tabBarCoordinator: TabBarCoordinator
    private let sessionStore: SessionStore
    private var cancellables = Set<AnyCancellable>()
    @Published private var rootViewModel: RootViewModel

    init(
        sessionStore: SessionStore,
        authManager: AuthManaging,
        tokenProvider: TokenProviding,
        feedService: FeedSession,
        commentService: CommentService,
        subnetService: SubnetSession,
        groupService: GroupSession,
        groupInviteService: GroupInviteSession
    ) {
        self.sessionStore = sessionStore
        self.tabBarCoordinator = TabBarCoordinator(
            authManager: authManager,
            tokenProvider: tokenProvider,
            feedService: feedService,
            commentService: commentService,
            subnetService: subnetService,
            groupService: groupService,
            groupInviteService: groupInviteService
        )
        self.loginCoordinator = LoginCoordinator(
            authManager: authManager,
            sessionStore: sessionStore
        )
        self.rootViewModel = RootViewModel(
            isAuthenticated: sessionStore.isAuthenticated
        )
        
        sessionStore.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.rootViewModel.isAuthenticated = newValue
            }
            .store(in: &cancellables)
    }

    func start() -> some View {
        RootView(
            viewModel: rootViewModel,
            makeContent: { [weak self] isAuthenticated in
                guard let self = self else { return AnyView(EmptyView()) }
                if isAuthenticated {
                    return AnyView(self.tabBarCoordinator.startWithTabBar())
                } else {
                    return AnyView(self.loginCoordinator.start())
                }
            }
        )
    }
    
    func handleDeeplink(_ url: URL) {
        print("🔗 Deeplink received in RootCoordinator: \(url)")
    }
    
    func handleNotification(_ userInfo: [AnyHashable: Any]) {
        print("🔔 Notification received in RootCoordinator: \(userInfo)")
    }
}
