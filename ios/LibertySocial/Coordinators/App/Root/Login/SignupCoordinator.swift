import SwiftUI
import Combine

@MainActor
final class SignupCoordinator {
    var onFinished: (() -> Void)?
    
    init() {
        
    }
    
    func start() -> some View {
        let signupModel = SignupModel()
        let viewModel = SignupViewModel(model: signupModel)
        viewModel.onSignupComplete = { [weak self] in
            self?.onFinished?()
        }
        return NavigationStack {
            SignupFlowView(viewModel: viewModel)
        }
    }
}
