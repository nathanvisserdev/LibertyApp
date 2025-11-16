import SwiftUI

enum NextView {
    case signupFlow
    case credentials
    case name
    case username
    case demographics
    case photo
    case about
    case phone
    case complete
}

@MainActor
final class SignupCoordinator {
    var onFinished: (() -> Void)?
    private var continueTapped: Bool = false
    private let sessionStore: SessionStore
    
    init(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }
    
    func start(nextView: NextView) -> some View {
        let viewModel = buildViewModel()
        switch nextView {
        case .signupFlow:
            return AnyView(SignupFlowView(viewModel: viewModel))
        case .credentials:
            return AnyView(SignupCredentialsView(viewModel: viewModel))
        case .name:
            return AnyView(SignupNameView(viewModel: viewModel))
        case .username:
            return AnyView(SignupUsernameView(viewModel: viewModel))
        case .demographics:
            return AnyView(SignupDemographicsView(viewModel: viewModel))
        case .photo:
            return AnyView(SignupPhotoView(viewModel: viewModel))
        case .about:
            return AnyView(SignupAboutView(viewModel: viewModel))
        case .phone:
            return AnyView(SignupPhoneView(viewModel: viewModel))
        case .complete:
            return AnyView(SignupWelcomeView(viewModel: viewModel))
        }
    }
    
    private func handleNavTap(nextView: NextView) -> Void {
        start(nextView: nextView)
    }
        
    private func buildViewModel() -> SignupViewModel {
        let model = SignupModel()
        let viewModel = SignupViewModel(
            model: model,
            sessionStore: sessionStore,
            onNextStep: { [weak self] nextView in
                self?.handleNavTap(nextView: nextView)
            },
            onSignupComplete: { [weak self] in
                self?.onFinished?()
            }
        )
        return viewModel
    }
}
    


