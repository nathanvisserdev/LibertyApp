import SwiftUI

@main
struct LibertySocialApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding
    private let notificationManager: NotificationManaging
    private let feedService: FeedSession
    private let groupInviteService: GroupInviteSession
    private let groupService: GroupSession
    private let subnetService: SubnetSession
    private let commentService: CommentService
    private let sessionStore: SessionStore
    private let appCoordinator: AppCoordinator

    @MainActor
    init() {
        let authManager = AuthManager()
        let tokenProvider: TokenProviding = authManager
        let notificationManager = NotificationManager(tokenProvider: tokenProvider)
        let feedService = FeedService()
        let groupInviteService = GroupInviteService()
        let groupService = GroupService()
        let subnetService = SubnetService()
        let commentService = DefaultCommentService(authManager: authManager)
        
        self.authManager = authManager
        self.tokenProvider = tokenProvider
        self.notificationManager = notificationManager
        self.feedService = feedService
        self.groupInviteService = groupInviteService
        self.groupService = groupService
        self.subnetService = subnetService
        self.commentService = commentService
        
        let sessionStore = SessionStore(
            authManager: authManager,
            tokenProvider: tokenProvider,
            notificationManager: notificationManager
        )
        self.sessionStore = sessionStore
        
        self.appCoordinator = AppCoordinator(
            sessionStore: sessionStore,
            authManager: authManager,
            tokenProvider: tokenProvider,
            feedService: feedService,
            commentService: commentService,
            subnetService: subnetService,
            groupService: groupService,
            groupInviteService: groupInviteService
        )
        defer {
            appDelegate.notificationManager = notificationManager
            appDelegate.appCoordinator = self.appCoordinator
        }
    }

    var body: some Scene {
        WindowGroup {
            appCoordinator.start()
                .onAppear { Task { await sessionStore.refresh() } }
                .onOpenURL { url in
                    appCoordinator.root.handleDeeplink(url)
                }
        }
    }
}

