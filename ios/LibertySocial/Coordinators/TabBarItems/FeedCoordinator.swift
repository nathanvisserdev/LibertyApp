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
    private let authSession: AuthSession
    private let authService: AuthServiceProtocol
    private let feedService: FeedSession
    private let commentService: CommentService

    init(authSession: AuthSession = AuthService.shared,
         authService: AuthServiceProtocol = AuthService.shared,
         feedService: FeedSession = FeedService.shared) {
        self.authSession = authSession
        self.authService = authService
        self.feedService = feedService
        self.commentService = CommentHTTPService(authSession: authSession) // ensure this init exists
    }

    func start() -> some View {
        NavigationStack { makeFeedView() }
    }

    // MARK: - Factory
    func makeFeedView() -> some View {
        let model = FeedModel(authService: authService)
        let vm = FeedViewModel(
            model: model,
            feedService: feedService,
            makeMediaVM: { MediaViewModel(mediaKey: $0) },
            auth: authService,
            commentService: commentService
        )
        vm.onLogout = { [weak self] in self?.handleLogout() }
        return FeedView(viewModel: vm)
    }

    // MARK: - Actions
    private func handleLogout() {
        authService.deleteToken()
        NotificationCenter.default.post(name: .init("UserDidLogout"), object: nil)
    }
}
