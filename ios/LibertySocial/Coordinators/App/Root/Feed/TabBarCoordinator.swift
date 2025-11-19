import SwiftUI

enum NextTabBarView {
    case feed
    case notificationsMenu
    case networkMenu
    case search
    case mainMenu(String)
    case createPost
    case profile(String)
}

@MainActor
final class TabBarCoordinator {
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding
    private let feedService: FeedSession
    private let subnetService: SubnetSession
    private let groupService: GroupSession
    private let groupInviteService: GroupInviteSession
    private let feedCoordinator: FeedCoordinator
    private let searchCoordinator: SearchCoordinator
    private let networkMenuCoordinator: NetworkMenuCoordinator
    private let notificationsMenuCoordinator: NotificationsMenuCoordinator
    private let mainMenuCoordinator: MainMenuCoordinator
    private let createPostCoordinator: CreatePostCoordinator
    private var activeProfileCoordinator: ProfileCoordinator?
    
    init(feedCoordinator: FeedCoordinator,
         authManager: AuthManaging,
         tokenProvider: TokenProviding,
         feedService: FeedSession,
         subnetService: SubnetSession,
         groupService: GroupSession,
         groupInviteService: GroupInviteSession) {
        self.feedCoordinator = feedCoordinator
        self.authManager = authManager
        self.tokenProvider = tokenProvider
        self.feedService = feedService
        self.subnetService = subnetService
        self.groupService = groupService
        self.groupInviteService = groupInviteService
        
        self.notificationsMenuCoordinator = NotificationsMenuCoordinator(
            authManager: authManager,
            tokenProvider: tokenProvider
        )
        
        self.networkMenuCoordinator = NetworkMenuCoordinator(
            authManager: authManager,
            tokenProvider: tokenProvider,
            groupService: groupService,
            subnetService: subnetService,
            groupInviteService: groupInviteService
        )
        
        self.searchCoordinator = SearchCoordinator(
            authManager: authManager,
            tokenProvider: tokenProvider
        )
        
        self.mainMenuCoordinator = MainMenuCoordinator(
            authManager: authManager,
            tokenProvider: tokenProvider
        )
        
        self.createPostCoordinator = CreatePostCoordinator(
            authManager: authManager,
            tokenProvider: tokenProvider,
            feedService: feedService,
            subnetService: subnetService
        )
        
        wireCallbacks()
    }

    convenience init(authManager: AuthManaging,
                     tokenProvider: TokenProviding,
                     feedService: FeedSession,
                     commentService: CommentService,
                     subnetService: SubnetSession,
                     groupService: GroupSession,
                     groupInviteService: GroupInviteSession) {
        let feed = FeedCoordinator(
            tokenProvider: tokenProvider,
            authManager: authManager,
            feedService: feedService,
            commentService: commentService
        )
        self.init(feedCoordinator: feed,
                  authManager: authManager,
                  tokenProvider: tokenProvider,
                  feedService: feedService,
                  subnetService: subnetService,
                  groupService: groupService,
                  groupInviteService: groupInviteService)
    }
    
    private func wireCallbacks() {
        feedCoordinator.onUserSelected = { [weak self] userId in
            self?.showProfile(userId: userId)
        }
        mainMenuCoordinator.onLogout = { [weak self] in
            self?.authManager.logout()
        }
    }
    
    private func showProfile(userId: String) {
        activeProfileCoordinator = ProfileCoordinator(
            userId: userId,
            authManager: authManager,
            tokenProvider: tokenProvider
        )
    }
    
    func start(nextView: NextTabBarView) -> some View {
        switch nextView {
        case .feed:
            return AnyView(feedCoordinator.start())
        case .notificationsMenu:
            return AnyView(notificationsMenuCoordinator.start())
        case .networkMenu:
            return AnyView(networkMenuCoordinator.start(nextView: .networkMenu))
        case .createPost:
            return AnyView(createPostCoordinator.start())
        case .search:
            return AnyView(searchCoordinator.start())
        case .mainMenu(let userId):
            return AnyView(mainMenuCoordinator.start(userId: userId))
        case .profile(let userId):
            showProfile(userId: userId)
            if let coordinator = activeProfileCoordinator {
                return AnyView(coordinator.start())
            }
            return AnyView(EmptyView())
        }
    }
    
    func startWithTabBar() -> some View {
        let feedView = start(nextView: .feed)
        
        let viewModel = TabBarViewModel(
            model: TabBarModel(AuthManagerBadName: authManager),
            onTabSelected: { _ in },
            notificationsMenuTapped: { },
            networkMenuTapped: { },
            createPostTapped: { },
            searchTapped: { },
            onProfileTapped: { _ in }
        )
        
        viewModel.onShowNotificationsMenu = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .notificationsMenu))
        }
        
        viewModel.onShowNetworkMenu = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .networkMenu))
        }
        
        viewModel.onShowSearch = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .search))
        }
        
        viewModel.onShowProfile = { [weak self] in
            guard let self = self,
                  let userId = viewModel.currentUserId else {
                return AnyView(EmptyView())
            }
            return AnyView(self.start(nextView: .mainMenu(userId)))
        }
        
        viewModel.onShowCreatePost = { [weak self] in
            guard let self = self else {
                return AnyView(EmptyView())
            }
            return AnyView(self.start(nextView: .createPost))
        }
        
        return feedView
            .safeAreaInset(edge: .bottom) {
                TabBarView(viewModel: viewModel)
                    .ignoresSafeArea(edges: .bottom)
            }
            .sheet(isPresented: Binding(
                get: { [weak self] in
                    self?.activeProfileCoordinator != nil
                },
                set: { [weak self] newValue in
                    if !newValue {
                        self?.activeProfileCoordinator = nil
                    }
                }
            )) {
                if let coordinator = self.activeProfileCoordinator {
                    coordinator.start()
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
            }
    }
}

enum TabBarItem {
    case notifications
    case networkMenu
    case search
    case profile
}
