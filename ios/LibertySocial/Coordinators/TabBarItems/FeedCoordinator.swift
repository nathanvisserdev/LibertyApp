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

    init(TokenProvider: TokenProviding,
         AuthManager: AuthManaging,
         feedService: FeedSession,
         commentService: CommentService) {
        self.TokenProvider = TokenProvider
        self.AuthManager = AuthManager
        self.feedService = feedService
        self.commentService = commentService
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
            makeMediaVM: { key in
                let mediaModel = MediaModel(TokenProvider: self.TokenProvider)
                return MediaViewModel(mediaKey: key, model: mediaModel)
            },
            auth: AuthManager,
            commentService: commentService
        )
        return FeedView(viewModel: vm)
    }

}
