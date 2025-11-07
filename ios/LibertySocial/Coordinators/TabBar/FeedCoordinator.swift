//
//  FeedCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-01-28.
//

import SwiftUI
import Combine

enum FeedRoute: Hashable {
    case profile(String)
}

final class FeedNavPathStore: ObservableObject {
    @Published var path = NavigationPath()
}

@MainActor
final class FeedCoordinator: ObservableObject {
    private let nav = FeedNavPathStore()
    private let tokenProvider: TokenProviding
    private let authManager: AuthManaging
    private let feedService: FeedSession
    private let commentService: CommentService

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
        NavigationStack(path: Binding(
            get: { self.nav.path },
            set: { self.nav.path = $0 }
        )) {
            makeFeedView()
                .navigationDestination(for: FeedRoute.self) { route in
                    switch route {
                    case .profile(let id):
                        self.makeProfileView(userId: id)
                    }
                }
        }
    }
    
    func openProfile(_ id: String) {
        nav.path.append(FeedRoute.profile(id))
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
                self?.openProfile(userId)
            }
        )
        return FeedView(viewModel: vm)
    }
    
    private func makeProfileView(userId: String) -> some View {
        ProfileCoordinator(
            userId: userId,
            authenticationManager: authManager,
            tokenProvider: tokenProvider
        ).start()
    }
}

