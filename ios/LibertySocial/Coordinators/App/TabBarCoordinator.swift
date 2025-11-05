//
//  TabBarCoordinator.swift
//  LibertySocial
//
//  Created by AI Assistant on 2025-10-24.
//

import SwiftUI

@MainActor
final class TabBarCoordinator {
    private let feedCoordinator: FeedCoordinator
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding

    init(feedCoordinator: FeedCoordinator,
         authManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.feedCoordinator = feedCoordinator
        self.authManager = authManager
        self.tokenProvider = tokenProvider
    }

    convenience init(authManager: AuthManaging,
                     tokenProvider: TokenProviding,
                     feedService: FeedSession,
                     commentService: CommentService) {
        let feed = FeedCoordinator(
            TokenProvider: tokenProvider,
            AuthManager: authManager,
            feedService: feedService,
            commentService: commentService
        )
        self.init(feedCoordinator: feed,
                  authManager: authManager,
                  tokenProvider: tokenProvider)
    }

    func start() -> some View {
        feedCoordinator.start()
            .safeAreaInset(edge: .bottom) {
                let vm = TabBarViewModel(model: TabBarModel(AuthManager: authManager))
                TabBarView(
                    viewModel: vm,
                    makeNetworkMenuCoordinator: {
                        NetworkMenuCoordinator(
                            authenticationManager: self.authManager,
                            tokenProvider: self.tokenProvider
                        )
                    },
                    makeProfileMenuCoordinator: {
                        ProfileMenuCoordinator(
                            authenticationManager: self.authManager,
                            tokenProvider: self.tokenProvider
                        )
                    },
                    makeSearchCoordinator: {
                        SearchCoordinator(
                            authenticationManager: self.authManager,
                            tokenProvider: self.tokenProvider
                        )
                    }
                )
                .ignoresSafeArea(edges: .bottom)
            }
    }
}
