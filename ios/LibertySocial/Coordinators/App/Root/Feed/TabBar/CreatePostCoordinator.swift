import SwiftUI

@MainActor
final class CreatePostCoordinator {
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding
    private let feedService: FeedSession
    private let subnetService: SubnetSession
    
    init(authManager: AuthManaging,
         tokenProvider: TokenProviding,
         feedService: FeedSession,
         subnetService: SubnetSession) {
        self.authManager = authManager
        self.tokenProvider = tokenProvider
        self.feedService = feedService
        self.subnetService = subnetService
    }
    
    func start() -> some View {
        let model = CreatePostModel(
            TokenProvider: tokenProvider,
            subnetSession: subnetService
        )
        let viewModel = CreatePostViewModel(
            model: model,
            feedService: feedService
        )
        return CreatePostView(viewModel: viewModel)
    }
}
