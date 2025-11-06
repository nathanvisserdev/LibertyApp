//
//  RootCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-11-04.
//

import SwiftUI
import Combine

@MainActor
final class RootCoordinator: ObservableObject {
    private let tabBarCoordinator: TabBarCoordinator
    private let loginCoordinator: LoginCoordinator
    
    @Published private var rootViewModel: RootViewModel

    init(tabBarCoordinator: TabBarCoordinator,
         loginCoordinator: LoginCoordinator,
         initialAuthenticationState: Bool) {
        self.tabBarCoordinator = tabBarCoordinator
        self.loginCoordinator = loginCoordinator
        
        // Step 1: Initialize view model with model and initial state only
        // Does NOT receive SessionStore - only the initial boolean value
        // Does NOT capture `self` yet - avoiding "self used before being initialized" error
        self.rootViewModel = RootViewModel(
            model: RootModel(),
            isAuthenticated: initialAuthenticationState
        )
        
        // Step 2: After `self` is fully initialized, assign the callback separately
        // This two-step pattern ensures memory safety and proper initialization order
        self.rootViewModel.onAuthenticationInvalidated = { [weak self] in
            self?.handleAuthenticationInvalidated()
        }
    }

    /// Container for the authenticated app
    func start() -> some View {
        return RootView(
            viewModel: rootViewModel,
            tabBarCoordinator: tabBarCoordinator,
            loginCoordinator: loginCoordinator
        )
    }
    
    // MARK: - Public Methods
    
    /// Called by AppCoordinator to relay authentication state changes
    /// Updates the view model, which triggers reactive UI updates in RootView
    func updateAuthenticationState(_ isAuthenticated: Bool) {
        // Mirror the state into the view model
        // The didSet will trigger callback if transitioning to false
        rootViewModel.isAuthenticated = isAuthenticated
    }
    
    // MARK: - Private Methods
    
    /// Handles when authentication becomes invalid
    private func handleAuthenticationInvalidated() {
        // Coordinator handles rerouting to login flow
        // The view will automatically switch to loginCoordinator due to reactive binding
        print("🔓 Authentication invalidated - routing to login flow")
    }
    
    // MARK: - External Entry Points
    
    /// Handles deeplink URLs from the app
    /// Delegates to appropriate child coordinators for intent-specific handling
    func handleDeeplink(_ url: URL) {
        // TODO: Parse URL and delegate to appropriate child coordinator
        // For now, log the deeplink
        print("🔗 Deeplink received in RootCoordinator: \(url)")
        
        // Example future implementation:
        // - Parse URL into intent
        // - Delegate to tabBarCoordinator or other child coordinators
        // - Handle authentication checks if needed
    }
    
    /// Handles notification taps from the app
    /// Delegates to appropriate child coordinators for intent-specific handling
    func handleNotification(_ userInfo: [AnyHashable: Any]) {
        // TODO: Parse notification payload and delegate to appropriate child coordinator
        // For now, log the notification
        print("🔔 Notification received in RootCoordinator: \(userInfo)")
        
        // Example future implementation:
        // - Parse notification payload into intent
        // - Delegate to tabBarCoordinator or other child coordinators
        // - Handle authentication checks if needed
    }
}
