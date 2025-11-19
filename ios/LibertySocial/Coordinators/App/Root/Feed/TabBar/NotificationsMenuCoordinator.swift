import SwiftUI

@MainActor
final class NotificationsMenuCoordinator {
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding
    
    init(authManager: AuthManaging, tokenProvider: TokenProviding) {
        self.authManager = authManager
        self.tokenProvider = tokenProvider
    }
    
    func start() -> some View {
        let model = NotificationsMenuModel(
            TokenProvider: tokenProvider,
            AuthManagerBadName: authManager
        )
        let viewModel = NotificationsMenuViewModel(model: model)
        return NotificationsMenuView(viewModel: viewModel)
    }
}
