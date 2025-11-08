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
    // MARK: - Dependencies
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding
    
    // MARK: - Long-lived Child Coordinators (one per tab)
    private let feedCoordinator: FeedCoordinator
    private let searchCoordinator: SearchCoordinator
    private let networkMenuCoordinator: NetworkMenuCoordinator
    private let notificationsMenuCoordinator: NotificationsMenuCoordinator
    private let profileMenuCoordinator: ProfileMenuCoordinator
    
    // MARK: - Transient/Ephemeral Child Coordinators
    private var activeProfileCoordinator: ProfileCoordinator?
    private var createPostCoordinator: CreatePostCoordinator?
    
    // MARK: - Published State
    @Published var isShowingProfile: Bool = false
    @Published var isShowingCreatePost: Bool = false

    // MARK: - Initializers
    
    init(feedCoordinator: FeedCoordinator,
         authManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.feedCoordinator = feedCoordinator
        self.authManager = authManager
        self.tokenProvider = tokenProvider
        
        // Initialize all tab coordinators here
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
        
        // Wire callbacks after initialization
        wireCallbacks()
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
    
    // MARK: - Callback Wiring
    
    /// Wire all child coordinator callbacks to route through this coordinator
    private func wireCallbacks() {
        // FeedCoordinator callbacks
        feedCoordinator.onUserSelected = { [weak self] userId in
            self?.showProfile(userId: userId)
        }
        
        // ProfileMenuCoordinator callbacks
        profileMenuCoordinator.onLogout = { [weak self] in
            self?.authManager.logout()
        }
        
        // Note: profileMenuCoordinator.onUserSelected is not wired here
        // to preserve the original profile menu navigation behavior
    }
    
    // MARK: - Cross-Tab Navigation
    
    /// Centralized method to show any user profile (from any tab)
    func showProfile(userId: String) {
        activeProfileCoordinator = ProfileCoordinator(
            userId: userId,
            authenticationManager: authManager,
            tokenProvider: tokenProvider
        )
        isShowingProfile = true
    }
    
    /// Show create post flow
    private func showCreatePost() {
        createPostCoordinator = CreatePostCoordinator()
        isShowingCreatePost = true
    }
    
    // MARK: - Tab Switching
    
    /// Switch to a specific tab and deactivate transient state in other tabs
    func switchTo(_ tab: TabBarTab) {
        // Dismiss any active overlays
        isShowingProfile = false
        isShowingCreatePost = false
        
        // Additional cleanup for tab coordinators could go here
        // e.g., resetting search state when switching away from search
    }
    
    // MARK: - View Building
    
    func start() -> some View {
        // Call start() on each child coordinator to obtain their root views
        let feedView = feedCoordinator.start()
        let notificationsView = notificationsMenuCoordinator.makeView()
        let networkMenuView = networkMenuCoordinator.makeView()
        let searchView = searchCoordinator.makeView()
        
        // Create the view model
        let vm = TabBarViewModel(
            model: TabBarModel(AuthManager: authManager),
            onTabSelected: { [weak self] tab in
                self?.switchTo(tab)
            },
            onNotificationsTapped: { [weak self] in
                self?.notificationsMenuCoordinator.showNotifications()
            },
            onNetworkMenuTapped: { [weak self] in
                self?.networkMenuCoordinator.showNetworkMenu()
            },
            onComposeTapped: { [weak self] in
                self?.showCreatePost()
            },
            onSearchTapped: { [weak self] in
                self?.searchCoordinator.showSearch()
            },
            onProfileTapped: { [weak self] id in
                self?.profileMenuCoordinator.showProfile(userId: id)
            }
        )
        
        // Wire up the view factories for sheets
        vm.onShowNotificationsMenu = {
            AnyView(notificationsView)
        }
        vm.onShowNetworkMenu = {
            AnyView(networkMenuView)
        }
        vm.onShowSearch = {
            AnyView(searchView)
        }
        vm.onShowProfile = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.profileMenuCoordinator.makeView())
        }
        vm.onShowCreatePost = { [weak self] in
            guard let coordinator = self?.createPostCoordinator else {
                return AnyView(EmptyView())
            }
            return AnyView(coordinator.start())
        }
        
        return feedView
            .safeAreaInset(edge: .bottom) {
                TabBarView(viewModel: vm)
                    .ignoresSafeArea(edges: .bottom)
            }
            .sheet(
                isPresented: Binding(
                    get: { self.isShowingProfile },
                    set: { [weak self] newValue in
                        self?.isShowingProfile = newValue
                        if newValue == false {
                            self?.activeProfileCoordinator = nil
                        }
                    }
                )
            ) {
                if let coordinator = self.activeProfileCoordinator {
                    coordinator.start()
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
            }
    }
}

// MARK: - Tab Enum

enum TabBarTab {
    case feed
    case notifications
    case networkMenu
    case search
    case profile
}
