import SwiftUI
import Combine

@MainActor
final class LoginCoordinator {
    private let authManager: AuthManaging
    private let sessionStore: SessionStore
    private let signupCoordinator: SignupCoordinator
    
    init(authManager: AuthManaging, sessionStore: SessionStore) {
        self.authManager = authManager
        self.sessionStore = sessionStore
        self.signupCoordinator = SignupCoordinator(sessionStore: sessionStore)
    }
    
    func start() -> some View {
        LoginCoordinatorHostView(coordinator: self)
    }
    
    fileprivate func makeLoginView(onSignupTapped: @escaping () -> Void) -> some View {
        let loginModel = LoginModel(authManager: authManager)
        let viewModel = LoginViewModel(
            model: loginModel,
            sessionStore: sessionStore,
            onTap: nil,
            onSignupTapped: onSignupTapped
        )
        return LoginView(viewModel: viewModel)
    }
    
    fileprivate func makeSignupView(onDismiss: @escaping () -> Void) -> some View {
        signupCoordinator.onFinished = onDismiss
        return signupCoordinator.start(nextView: NextView.signupFlow)
    }
}

private struct LoginCoordinatorHostView: View {
    let coordinator: LoginCoordinator
    
    @State private var isShowingSignup = false
    
    var body: some View {
        coordinator.makeLoginView(onSignupTapped: {
            isShowingSignup = true
        })
        .fullScreenCover(isPresented: $isShowingSignup) {
            coordinator.makeSignupView(onDismiss: {
                isShowingSignup = false
            })
        }
    }
}
