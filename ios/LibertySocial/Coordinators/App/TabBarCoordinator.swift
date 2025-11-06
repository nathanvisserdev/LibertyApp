//
//  TabBarCoordinator.swift
//  LibertySocial
//
//  Created by AI Assistant on 2025-10-24.
//

import SwiftUI
import Combine

@MainActor
final class TabBarCoordinator: ObservableObject {
    private let feedCoordinator: FeedCoordinator
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding
    private let notificationsMenuCoordinator: NotificationsMenuCoordinator
    private let networkMenuCoordinator: NetworkMenuCoordinator
    private let searchCoordinator: SearchCoordinator
    private let profileMenuCoordinator: ProfileMenuCoordinator
    private var createPostCoordinator: CreatePostCoordinator?
    
    // MARK: - Published State
    @Published var isShowingCreatePost: Bool = false

    init(feedCoordinator: FeedCoordinator,
         authManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.feedCoordinator = feedCoordinator
        self.authManager = authManager
        self.tokenProvider = tokenProvider
        self.notificationsMenuCoordinator = NotificationsMenuCoordinator()
        self.networkMenuCoordinator = NetworkMenuCoordinator(
            authenticationManager: authManager,
            tokenProvider: tokenProvider
        )
        self.searchCoordinator = SearchCoordinator(
            authenticationManager: authManager,
            tokenProvider: tokenProvider
        )
        self.profileMenuCoordinator = ProfileMenuCoordinator(
            authenticationManager: authManager,
            tokenProvider: tokenProvider
        )
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

    private func showNotificationsMenuCoordinator() {
        notificationsMenuCoordinator.showNotifications()
    }
    
    private func showNetworkMenuCoordinator() {
        networkMenuCoordinator.showNetworkMenu()
    }
    
    private func showSearchCoordinator() {
        searchCoordinator.showSearch()
    }
    
    private func showProfile(userId: String) {
        profileMenuCoordinator.showProfile(userId: userId)
    }
    
    private func showCreatePost() {
        createPostCoordinator = CreatePostCoordinator()
        isShowingCreatePost = true
    }
    
    // MARK: - Public Routing Helpers
    
    /// Routes to a profile from the Feed tab
    func openProfileFromFeed(_ userId: String) {
        feedCoordinator.openProfile(userId)
    }
    
    /// Routes to a user's followers list from the Profile tab
    func openFollowersFromProfile(_ userId: String) {
        profileMenuCoordinator.openFollowers(for: userId)
    }
    
    /// Routes to a user's following list from the Profile tab
    func openFollowingFromProfile(_ userId: String) {
        profileMenuCoordinator.openFollowing(for: userId)
    }
    
    /// Builds the CreatePostView
    func makeCreatePostView() -> some View {
        guard let coordinator = createPostCoordinator else {
            return AnyView(EmptyView())
        }
        return AnyView(coordinator.start())
    }

    func start() -> some View {
        feedCoordinator.start()
            .safeAreaInset(edge: .bottom) {
                let vm = TabBarViewModel(
                    model: TabBarModel(AuthManager: authManager),
                    onNotificationsTapped: { [weak self] in
                        self?.showNotificationsMenuCoordinator()
                    },
                    onNetworkMenuTapped: { [weak self] in
                        self?.showNetworkMenuCoordinator()
                    },
                    onComposeTapped: { [weak self] in
                        self?.showCreatePost()
                    },
                    onSearchTapped: { [weak self] in
                        self?.showSearchCoordinator()
                    },
                    onProfileTapped: { [weak self] id in
                        self?.showProfile(userId: id)
                    }
                )
                TabBarView(
                    viewModel: vm,
                    tabBarCoordinator: self,
                    notificationsMenuCoordinator: notificationsMenuCoordinator,
                    networkMenuCoordinator: networkMenuCoordinator,
                    searchCoordinator: searchCoordinator,
                    profileMenuCoordinator: profileMenuCoordinator
                )
                .ignoresSafeArea(edges: .bottom)
            }
    }
}
