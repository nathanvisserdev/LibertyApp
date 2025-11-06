//
//  Coordinator.swift
//  LibertySocial
//
//  Created by AI Assistant on 2025-10-24.
//

import SwiftUI
import Combine

// MARK: - AppRoute
/// Represents the target destinations for deeplinks and notifications
enum AppRoute: Equatable {
    case profile(String)
    case followers(String)
    case following(String)
    // Add more routes as needed: case post(String), case group(String), etc.
}

/// Top-level coordinator that handles application-wide navigation including:
/// - Deeplink handling (e.g., libertysocial://profile/user123)
/// - Push notification routing
/// - Authentication-aware navigation (queues routes until authenticated)
/// - Delegation to tab coordinators without global state
///
/// **Architecture:**
/// - Parses external intents (URLs, notifications) into AppRoute enums
/// - Selects the appropriate tab coordinator
/// - Delegates to that coordinator's public routing methods
/// - Queues routes when not authenticated and replays after login
/// - Maintains strict DI: all dependencies injected via initializers
@MainActor
final class AppCoordinator: ObservableObject {
    private var rootCoordinator: RootCoordinator!
    private let tabBarCoordinator: TabBarCoordinator
    private let sessionStore: SessionStore
    
    // Queue for pending routes when not authenticated
    @Published private var pendingRoute: AppRoute?
    
    init(loginCoordinator: LoginCoordinator,
         sessionStore: SessionStore,
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
        self.tabBarCoordinator = tabBarCoordinator
        self.sessionStore = sessionStore
        
        // Create rootCoordinator after self is initialized
        self.rootCoordinator = RootCoordinator(
            tabBarCoordinator: tabBarCoordinator,
            loginCoordinator: loginCoordinator,
            onAuthenticationChanged: { [weak self] isAuthenticated in
                self?.handleAuthenticationChange(isAuthenticated: isAuthenticated)
            }
        )
    }
    
    /// Builds the main authenticated view with TabBar at root
    func start() -> some View {
        rootCoordinator.start()
    }
    
    // MARK: - External Entry Points (Deeplinks/Notifications)
    
    /// Handles deeplink or notification by routing to the appropriate tab and view
    /// - Parameter route: The route to navigate to
    /// - Note: If not authenticated, the route is queued and executed after login
    func handleRoute(_ route: AppRoute) {
        guard sessionStore.isAuthenticated else {
            // Queue the route for after authentication
            pendingRoute = route
            return
        }
        
        executeRoute(route)
    }
    
    /// Parses a URL and routes to the appropriate destination
    /// - Parameter url: The deeplink URL to parse
    /// Example URLs:
    /// - libertysocial://profile/user123
    func handleDeeplink(_ url: URL) {
        guard let route = parseDeeplink(url) else {
            print("Failed to parse deeplink: \(url)")
            return
        }
        handleRoute(route)
    }
    
    /// Handles a notification tap by extracting the route and navigating
    /// - Parameter userInfo: The notification's userInfo dictionary
    func handleNotification(userInfo: [AnyHashable: Any]) {
        guard let route = parseNotification(userInfo) else {
            print("Failed to parse notification: \(userInfo)")
            return
        }
        handleRoute(route)
    }
    
    // MARK: - Private Helpers
    
    private func parseDeeplink(_ url: URL) -> AppRoute? {
        // Example: libertysocial://profile/user123
        // Example: libertysocial://profile/user123/followers
        // Example: libertysocial://profile/user123/following
        guard url.scheme == "libertysocial" else { return nil }
        
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        guard !pathComponents.isEmpty else { return nil }
        
        switch pathComponents[0] {
        case "profile":
            guard pathComponents.count > 1 else { return nil }
            let userId = pathComponents[1]
            
            // Check for followers/following subpath
            if pathComponents.count > 2 {
                switch pathComponents[2] {
                case "followers":
                    return .followers(userId)
                case "following":
                    return .following(userId)
                default:
                    return .profile(userId)
                }
            }
            
            return .profile(userId)
        default:
            return nil
        }
    }
    
    private func parseNotification(_ userInfo: [AnyHashable: Any]) -> AppRoute? {
        // Example: ["type": "profile", "userId": "user123"]
        // Example: ["type": "followers", "userId": "user123"]
        // Example: ["type": "following", "userId": "user123"]
        guard let type = userInfo["type"] as? String else { return nil }
        
        switch type {
        case "profile":
            guard let userId = userInfo["userId"] as? String else { return nil }
            return .profile(userId)
        case "followers":
            guard let userId = userInfo["userId"] as? String else { return nil }
            return .followers(userId)
        case "following":
            guard let userId = userInfo["userId"] as? String else { return nil }
            return .following(userId)
        default:
            return nil
        }
    }
    
    private func executeRoute(_ route: AppRoute) {
        switch route {
        case .profile(let userId):
            // Route to Feed tab and push profile
            tabBarCoordinator.openProfileFromFeed(userId)
        case .followers(let userId):
            // Route to Profile tab and push followers list
            tabBarCoordinator.openFollowersFromProfile(userId)
        case .following(let userId):
            // Route to Profile tab and push following list
            tabBarCoordinator.openFollowingFromProfile(userId)
        }
    }
    
    private func handleAuthenticationChange(isAuthenticated: Bool) {
        guard isAuthenticated, let route = pendingRoute else { return }
        
        // Clear pending route and execute it
        pendingRoute = nil
        
        // Small delay to ensure UI is ready
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            executeRoute(route)
        }
    }
}
