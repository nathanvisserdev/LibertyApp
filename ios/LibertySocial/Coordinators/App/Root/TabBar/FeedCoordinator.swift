
import SwiftUI
import Combine

@MainActor
final class FeedCoordinator: ObservableObject {
    private let tokenProvider: TokenProviding
    private let authManager: AuthManaging
    private let feedService: FeedSession
    private let commentService: CommentService
    
    var onUserSelected: ((String) -> Void)?

    init(tokenProvider: TokenProviding,
         authManager: AuthManaging,
         feedService: FeedSession,
         commentService: CommentService) {
        self.tokenProvider = tokenProvider
        self.authManager = authManager
        self.feedService = feedService
        self.commentService = commentService
    }

    func start() -> some View {
        makeFeedView()
    }

    private func makeFeedView() -> some View {
        let model = FeedModel(AuthManagerBadName: authManager)
        let vm = FeedViewModel(
            model: model,
            feedService: feedService,
            makeMediaVM: { key in
                let mediaModel = MediaModel(TokenProvider: self.tokenProvider)
                return MediaViewModel(mediaKey: key, model: mediaModel)
            },
            auth: authManager,
            commentService: commentService,
            onShowProfile: { [weak self] userId in
                self?.onUserSelected?(userId)
            }
        )
        return FeedView(viewModel: vm)
    }
}

