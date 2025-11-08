
import SwiftUI
import Combine

@MainActor
final class TabBarCoordinator: ObservableObject {
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding
    
    private let feedCoordinator: FeedCoordinator
    private let searchCoordinator: SearchCoordinator
    private let networkMenuCoordinator: NetworkMenuCoordinator
    private let notificationsMenuCoordinator: NotificationsMenuCoordinator
    private let profileMenuCoordinator: ProfileMenuCoordinator
    
    private var activeProfileCoordinator: ProfileCoordinator?
    private var createPostCoordinator: CreatePostCoordinator?
    
    @Published var isShowingProfile: Bool = false
    @Published var isShowingCreatePost: Bool = false
    
    init(feedCoordinator: FeedCoordinator,
         authManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.feedCoordinator = feedCoordinator
        self.authManager = authManager
        self.tokenProvider = tokenProvider
        
        self.notificationsMenuCoordinator = NotificationsMenuCoordinator()
        self.networkMenuCoordinator = NetworkMenuCoordinator(
            authenticationManager: authManager,
            tokenProvider: tokenProvider
        )
        self.searchCoordinator = SearchCoordinator(
            authenticationManager: authManager,
            tokenProvider: tokenProvider
        )
        self.profileMenuCoordinator = ProfileMenuCoordinator(
            authenticationManager: authManager,
            tokenProvider: tokenProvider
        )
        
        wireCallbacks()
    }

    convenience init(authManager: AuthManaging,
                     tokenProvider: TokenProviding,
                     feedService: FeedSession,
                     commentService: CommentService) {
        let feed = FeedCoordinator(
            tokenProvider: tokenProvider,
            authManager: authManager,
            feedService: feedService,
            commentService: commentService
        )
        self.init(feedCoordinator: feed,
                  authManager: authManager,
                  tokenProvider: tokenProvider)
    }
    
    private func wireCallbacks() {
        feedCoordinator.onUserSelected = { [weak self] userId in
            self?.showProfile(userId: userId)
        }
        
        profileMenuCoordinator.onLogout = { [weak self] in
            self?.authManager.logout()
        }
    }
    
    func showProfile(userId: String) {
        activeProfileCoordinator = ProfileCoordinator(
            userId: userId,
            authenticationManager: authManager,
            tokenProvider: tokenProvider
        )
        isShowingProfile = true
    }
    
    private func showCreatePost() {
        createPostCoordinator = CreatePostCoordinator()
        isShowingCreatePost = true
    }
    
    func switchTo(_ tab: TabBarTab) {
        isShowingProfile = false
        isShowingCreatePost = false
    }
    
    func start() -> some View {
        let feedView = feedCoordinator.start()
        let notificationsView = notificationsMenuCoordinator.makeView()
        let networkMenuView = networkMenuCoordinator.makeView()
        let searchView = searchCoordinator.makeView()
        
        let viewModel = TabBarViewModel(
            model: TabBarModel(AuthManagerBadName: authManager),
            onTabSelected: { [weak self] tab in
                self?.switchTo(tab)
            },
            onNotificationsTapped: { [weak self] in
                self?.notificationsMenuCoordinator.showNotifications()
            },
            onNetworkMenuTapped: { [weak self] in
                self?.networkMenuCoordinator.showNetworkMenu()
            },
            onComposeTapped: { [weak self] in
                self?.showCreatePost()
            },
            onSearchTapped: { [weak self] in
                self?.searchCoordinator.showSearch()
            },
            onProfileTapped: { [weak self] id in
                self?.profileMenuCoordinator.showProfile(userId: id)
            }
        )
        
        viewModel.onShowNotificationsMenu = {
            AnyView(notificationsView)
        }
        viewModel.onShowNetworkMenu = {
            AnyView(networkMenuView)
        }
        viewModel.onShowSearch = {
            AnyView(searchView)
        }
        viewModel.onShowProfile = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.profileMenuCoordinator.makeView())
        }
        viewModel.onShowCreatePost = { [weak self] in
            guard let coordinator = self?.createPostCoordinator else {
                return AnyView(EmptyView())
            }
            return AnyView(coordinator.start())
        }
        
        return feedView
            .safeAreaInset(edge: .bottom) {
                TabBarView(viewModel: viewModel)
                    .ignoresSafeArea(edges: .bottom)
            }
            .sheet(
                isPresented: Binding(
                    get: { self.isShowingProfile },
                    set: { [weak self] newValue in
                        self?.isShowingProfile = newValue
                        if newValue == false {
                            self?.activeProfileCoordinator = nil
                        }
                    }
                )
            ) {
                if let coordinator = self.activeProfileCoordinator {
                    coordinator.start()
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
            }
    }
}

enum TabBarTab {
    case feed
    case notifications
    case networkMenu
    case search
    case profile
}
