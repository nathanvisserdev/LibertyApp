
import SwiftUI

final class LoginCoordinator {

    init() {
        
    }
    
    func start() -> some View {
        let viewModel = LoginViewModel()
        return LoginView(viewModel: viewModel)
    }
}
