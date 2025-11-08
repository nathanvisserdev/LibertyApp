
import Foundation
import Combine

@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var isAuthenticated = false

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


    func refresh() async {
        do { _ = try tokenProvider.getAuthToken() }
        catch {
            isAuthenticated = false
            return
        }

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


    private func handleLogoutSideEffects() {
        isAuthenticated = false
        UserDefaults.standard.set(false, forKey: "newConnectionRequest")
    }
}
