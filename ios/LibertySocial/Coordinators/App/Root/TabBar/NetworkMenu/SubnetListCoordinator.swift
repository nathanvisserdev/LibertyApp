
import SwiftUI
import Combine

@MainActor
final class SubnetListCoordinator: ObservableObject {
    @Published var isShowingSubnetMenu: Bool = false
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding

    init(authManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.authManager = authManager
        self.tokenProvider = tokenProvider
    }
    
    func showSubnetMenu() {
        isShowingSubnetMenu = true
    }

    func makeView() -> some View {
        let viewModel = SubnetListViewModel()
        return SubnetListView(viewModel: viewModel)
    }
}
