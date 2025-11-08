
import SwiftUI
import Combine

@MainActor
final class NotificationsMenuCoordinator: ObservableObject {
    @Published var isShowingNotifications: Bool = false
    
    init() {}
    
    func showNotifications() {
        isShowingNotifications = true
    }
    
    func makeView() -> some View {
        let viewModel = NotificationsMenuViewModel()
        return NotificationsMenuView(viewModel: viewModel)
    }
}
