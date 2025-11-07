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
            tokenProvider: tokenProvider,
            authManager: authManager,
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
    }
    
    func openProfileFromFeed(_ userId: String) {
        feedCoordinator.openProfile(userId)
    }
    
    func openFollowersFromProfile(_ userId: String) {
        profileMenuCoordinator.openFollowers(for: userId)
    }
    
    func openFollowingFromProfile(_ userId: String) {
        profileMenuCoordinator.openFollowing(for: userId)
    }

    func start() -> some View {
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
        
        vm.onShowNotificationsMenu = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.notificationsMenuCoordinator.makeView())
        }
        
        vm.onShowNetworkMenu = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.networkMenuCoordinator.makeView())
        }
        
        vm.onShowSearch = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.searchCoordinator.makeView())
        }
        
        vm.onShowProfile = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.profileMenuCoordinator.makeView())
        }
        
        vm.onShowCreatePost = { [weak self] in
            guard let self = self, let coordinator = self.createPostCoordinator else {
                return AnyView(EmptyView())
            }
            return AnyView(coordinator.start())
        }
        
        return feedCoordinator.start()
            .safeAreaInset(edge: .bottom) {
                TabBarView(viewModel: vm)
                    .ignoresSafeArea(edges: .bottom)
            }
    }
}
