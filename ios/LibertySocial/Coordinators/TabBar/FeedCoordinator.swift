//
//  FeedCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-01-28.
//

import SwiftUI
import Combine

// MARK: - FeedRoute
enum FeedRoute: Hashable {
    case profile(String)
}

// MARK: - FeedNavPathStore
final class FeedNavPathStore: ObservableObject {
    @Published var path = NavigationPath()
}

@MainActor
final class FeedCoordinator: ObservableObject {
    // MARK: - Navigation
    private let nav = FeedNavPathStore()
    
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
        FeedStackView(
            nav: nav,
            tokenProvider: TokenProvider,
            authManager: AuthManager,
            onShowProfile: { [weak self] id in
                self?.openProfile(id)
            }
        )
    }
    
    // MARK: - Navigation Actions
    func openProfile(_ id: String) {
        nav.path.append(FeedRoute.profile(id))
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
            commentService: commentService,
            onShowProfile: { [weak self] userId in
                self?.openProfile(userId)
            }
        )
        return FeedView(viewModel: vm)
    }
}

// MARK: - FeedStackView
struct FeedStackView: View {
    @ObservedObject var nav: FeedNavPathStore
    let tokenProvider: TokenProviding
    let authManager: AuthManaging
    let onShowProfile: (String) -> Void
    
    var body: some View {
        NavigationStack(
            path: Binding(
                get: { nav.path },
                set: { nav.path = $0 }
            )
        ) {
            makeFeedView()
                .navigationDestination(for: FeedRoute.self) { route in
                    switch route {
                    case .profile(let id):
                        ProfileCoordinator(
                            userId: id,
                            authenticationManager: authManager,
                            tokenProvider: tokenProvider
                        ).start()
                    }
                }
        }
    }
    
    private func makeFeedView() -> some View {
        let model = FeedModel(AuthManager: authManager)
        let feedService = FeedService()
        let commentService = DefaultCommentService(auth: authManager)
        let vm = FeedViewModel(
            model: model,
            feedService: feedService,
            makeMediaVM: { key in
                let mediaModel = MediaModel(TokenProvider: tokenProvider)
                return MediaViewModel(mediaKey: key, model: mediaModel)
            },
            auth: authManager,
            commentService: commentService,
            onShowProfile: onShowProfile
        )
        return FeedView(viewModel: vm)
    }
}

