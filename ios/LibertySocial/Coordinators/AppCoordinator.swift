
import SwiftUI
import Combine

@MainActor
final class AppCoordinator: ObservableObject {
    private let rootCoordinator: RootCoordinator
    private let sessionStore: SessionStore
    private var cancellables = Set<AnyCancellable>()
    
    var root: RootCoordinator {
        rootCoordinator
    }
    
    init(sessionStore: SessionStore,
         authManager: AuthManaging,
         tokenProvider: TokenProviding,
         feedService: FeedSession,
         commentService: CommentService) {
        
        self.sessionStore = sessionStore
        
        self.rootCoordinator = RootCoordinator(
            initialAuthenticationState: sessionStore.isAuthenticated,
            authManager: authManager,
            tokenProvider: tokenProvider,
            feedService: feedService,
            commentService: commentService
        )
        
        sessionStore.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self = self else { return }
                self.rootCoordinator.updateAuthenticationState(newValue)
            }
            .store(in: &cancellables)
    }
    
    func start() -> some View {
        rootCoordinator.start()
    }
}
