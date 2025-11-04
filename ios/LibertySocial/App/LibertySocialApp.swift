//
//  LibertySocialApp.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-02.
//

import SwiftUI

@main
struct LibertySocialApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    // DI
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding
    private let notificationManager: NotificationManaging

    // Session
    @StateObject private var session: SessionStore

    // Coordinators (use your existing initializers)
    private let appCoordinator = AppCoordinator()
    private let loginCoordinator = LoginCoordinator()

    init() {
        // Concrete implementations
        let authManager = AuthService()
        let tokenProvider: TokenProviding = authManager
        let notificationManager = NotificationManager(tokenProvider: tokenProvider)

        self.authManager = authManager
        self.tokenProvider = tokenProvider
        self.notificationManager = notificationManager

        // Inject into SessionStore
        _session = StateObject(
            wrappedValue: SessionStore(
                authManager: authManager,
                tokenProvider: tokenProvider,
                notificationManager: notificationManager
            )
        )

        // If AppDelegate exposes an injection point, wire it here:
        // appDelegate.notificationManager = notificationManager
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if session.isAuthenticated {
                    appCoordinator.start()
                } else {
                    loginCoordinator.start()
                }
            }
            .environmentObject(session)
            .onAppear { Task { await session.refresh() } }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active { Task { await session.refresh() } }
        }
    }
}

