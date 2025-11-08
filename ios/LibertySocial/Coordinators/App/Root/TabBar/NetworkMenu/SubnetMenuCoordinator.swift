
import SwiftUI
import Combine

@MainActor
final class SubnetMenuCoordinator: ObservableObject {
    
    @Published var isShowingSubnetMenu: Bool = false
    
    private let authenticationManager: AuthManaging
    private let tokenProvider: TokenProviding

    init(authenticationManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.authenticationManager = authenticationManager
        self.tokenProvider = tokenProvider
    }
    
    
    func showSubnetMenu() {
        isShowingSubnetMenu = true
    }

    func makeView() -> some View {
        let viewModel = SubnetMenuViewModel()
        return SubnetMenuView(viewModel: viewModel)
    }
}
