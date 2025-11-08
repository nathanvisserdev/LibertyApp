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
    private let tokenProvider: TokenProviding
    private let authManager: AuthManaging
    private let feedService: FeedSession
    private let commentService: CommentService
    
    // Callback for when a user is selected (to be wired by parent coordinator)
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
        let model = FeedModel(AuthManager: authManager)
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
                // Signal to parent coordinator for centralized navigation
                self?.onUserSelected?(userId)
            }
        )
        return FeedView(viewModel: vm)
    }
}

