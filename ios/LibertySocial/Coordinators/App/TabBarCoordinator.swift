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
    private let notificationsMenuCoordinator: NotificationsMenuCoordinator
    private let networkMenuCoordinator: NetworkMenuCoordinator
    private let searchCoordinator: SearchCoordinator
    private let profileMenuCoordinator: ProfileMenuCoordinator

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
                    onSearchTapped: { [weak self] in
                        self?.showSearchCoordinator()
                    },
                    onProfileTapped: { [weak self] id in
                        self?.showProfile(userId: id)
                    }
                )
                TabBarView(
                    viewModel: vm,
                    notificationsMenuCoordinator: notificationsMenuCoordinator,
                    networkMenuCoordinator: networkMenuCoordinator,
                    searchCoordinator: searchCoordinator,
                    profileMenuCoordinator: profileMenuCoordinator
                )
                .ignoresSafeArea(edges: .bottom)
            }
    }
}
