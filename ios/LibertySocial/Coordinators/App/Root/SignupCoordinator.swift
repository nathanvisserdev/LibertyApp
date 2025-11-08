
import SwiftUI

final class SignupCoordinator {
    
    init() {
        
    }
    
    func start() -> some View {
        let viewModel = SignupViewModel()
        return SignupFlowView(viewModel: viewModel)
    }
}
