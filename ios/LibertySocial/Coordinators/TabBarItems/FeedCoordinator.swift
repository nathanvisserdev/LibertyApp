//
//  FeedCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-01-28.
//

import SwiftUI
import Combine

@MainActor
final class FeedCoordinator: ObservableObject {
    // MARK: - Dependencies
    private let TokenProvider: TokenProviding
    private let AuthManager: AuthManaging
    private let feedService: FeedSession
    private let commentService: CommentService

    init(TokenProvider: TokenProviding = AuthService.shared,
         AuthManager: AuthManaging = AuthService.shared,
         feedService: FeedSession = FeedService.shared) {
        self.TokenProvider = TokenProvider
        self.AuthManager = AuthManager
        self.feedService = feedService
        self.commentService = CommentHTTPService(TokenProvider: TokenProvider) // ensure this init exists
    }

    func start() -> some View {
        NavigationStack { makeFeedView() }
    }

    // MARK: - Factory
    func makeFeedView() -> some View {
        let model = FeedModel(AuthManager: AuthManager)
        let vm = FeedViewModel(
            model: model,
            feedService: feedService,
            makeMediaVM: { MediaViewModel(mediaKey: $0) },
            auth: AuthManager,
            commentService: commentService
        )
        return FeedView(viewModel: vm)
    }
}
