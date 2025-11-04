//
//  SessionStore.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-07.
//

import Foundation
import Combine

@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var isAuthenticated = false

    // Dependencies
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding
    private let notificationManager: NotificationManaging

    private var cancellables = Set<AnyCancellable>()

    init(
        authManager: AuthManaging,
        tokenProvider: TokenProviding,
        notificationManager: NotificationManaging
    ) {
        self.authManager = authManager
        self.tokenProvider = tokenProvider
        self.notificationManager = notificationManager

        NotificationCenter.default.publisher(for: .userDidLogout)
            .sink { [weak self] _ in
                Task { @MainActor in self?.handleLogoutSideEffects() }
            }
            .store(in: &cancellables)

        Task { await refresh() }
    }

    // MARK: - Public

    func refresh() async {
        // Local presence check
        do { _ = try tokenProvider.getAuthToken() }
        catch {
            isAuthenticated = false
            return
        }

        // Server validation
        do {
            _ = try await authManager.fetchCurrentUserTyped()
            isAuthenticated = true
        } catch {
            authManager.deleteToken()
            isAuthenticated = false
        }
    }

    func logout() {
        Task { @MainActor in
            await notificationManager.unregisterDevice()
            authManager.deleteToken()
            isAuthenticated = false
            UserDefaults.standard.set(false, forKey: "newConnectionRequest")
        }
    }

    // MARK: - Private

    private func handleLogoutSideEffects() {
        isAuthenticated = false
        UserDefaults.standard.set(false, forKey: "newConnectionRequest")
    }
}
