//
//  Coordinator.swift
//  LibertySocial
//
//  Created by AI Assistant on 2025-10-24.
//

import SwiftUI
import Combine

/// Top-level coordinator that serves as the dependency composer and entry point.
/// 
/// **Responsibilities:**
/// - Initializes and owns shared services (authentication, token provider, feed service, etc.)
/// - Composes and injects dependencies into child coordinators
/// - Creates and owns the `RootCoordinator` which manages app-level presentation
/// - **Single observer** of `SessionStore.$isAuthenticated` - relays updates down to RootCoordinator
/// - Does NOT handle navigation, routing, or deeplinks (delegated to child coordinators)
///
/// **Architecture:**
/// - Pure dependency injection container with authentication observation
/// - No routing logic - all navigation lives in child coordinators
/// - RootCoordinator owns TabBarCoordinator and LoginCoordinator
/// - Child coordinators handle their own presentation and navigation patterns
@MainActor
final class AppCoordinator: ObservableObject {
    private let rootCoordinator: RootCoordinator
    private let sessionStore: SessionStore
    private var cancellables = Set<AnyCancellable>()
    
    /// Exposes the root coordinator for external entry points (deeplinks, notifications)
    var root: RootCoordinator {
        rootCoordinator
    }
    
    init(loginCoordinator: LoginCoordinator,
         sessionStore: SessionStore,
         authManager: AuthManaging,
         tokenProvider: TokenProviding,
         feedService: FeedSession,
         commentService: CommentService) {
        
        self.sessionStore = sessionStore
        
        // Create TabBarCoordinator with all required dependencies
        let tabBarCoordinator = TabBarCoordinator(
            authManager: authManager,
            tokenProvider: tokenProvider,
            feedService: feedService,
            commentService: commentService
        )
        
        // Create RootCoordinator - it owns TabBarCoordinator and LoginCoordinator
        // Pass initial authentication state, NOT the SessionStore itself
        self.rootCoordinator = RootCoordinator(
            tabBarCoordinator: tabBarCoordinator,
            loginCoordinator: loginCoordinator,
            initialAuthenticationState: sessionStore.isAuthenticated
        )
        
        // AppCoordinator is the ONLY layer that observes SessionStore
        // Updates flow one-way downward: SessionStore → AppCoordinator → RootCoordinator → RootViewModel
        sessionStore.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self = self else { return }
                // Relay authentication state changes down to RootCoordinator
                self.rootCoordinator.updateAuthenticationState(newValue)
            }
            .store(in: &cancellables)
    }
    
    /// Builds the root view - entry point for the app
    func start() -> some View {
        rootCoordinator.start()
    }
}
