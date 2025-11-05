//
//  Coordinator.swift
//  LibertySocial
//
//  Created by AI Assistant on 2025-10-24.
//

import SwiftUI

@MainActor
final class AppCoordinator {
    private let rootCoordinator: RootCoordinator
    
    init(loginCoordinator: LoginCoordinator,
         authManager: AuthManaging,
         tokenProvider: TokenProviding,
         feedService: FeedSession,
         commentService: CommentService) {
        let tabBarCoordinator = TabBarCoordinator(
            authManager: authManager,
            tokenProvider: tokenProvider,
            feedService: feedService,
            commentService: commentService
        )
        self.rootCoordinator = RootCoordinator(
            tabBarCoordinator: tabBarCoordinator,
            loginCoordinator: loginCoordinator
        )
    }
    /// Builds the main authenticated view with TabBar at root
    func start() -> some View {
        rootCoordinator.start()
    }
}
