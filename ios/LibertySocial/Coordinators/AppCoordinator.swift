
import SwiftUI
import Combine

@MainActor
final class AppCoordinator: ObservableObject {
    private let rootCoordinator: RootCoordinator
    var root: RootCoordinator { rootCoordinator }
    
    init(sessionStore: SessionStore,
         authManager: AuthManaging,
         tokenProvider: TokenProviding,
         feedService: FeedSession,
         commentService: CommentService) {
        self.rootCoordinator = RootCoordinator(
            sessionStore: sessionStore,
            authManager: authManager,
            tokenProvider: tokenProvider,
            feedService: feedService,
            commentService: commentService
        )
    }
    
    func start() -> some View {
        rootCoordinator.start()
    }
}
