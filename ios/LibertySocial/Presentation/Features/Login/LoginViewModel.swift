
import Foundation
import Combine
import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {
    private let model: LoginModel
    private let sessionStore: SessionStore
    private let onSignupTapped: () -> Void
    private let onTap: ((LoginItem) -> Void)?
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isSecure: Bool = true
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var me: [String: Any]?
    @Published var showTestUsersAlert: Bool = false
    @Published var testUsersMessage: String?
    
    init(model: LoginModel,
         sessionStore: SessionStore,
         onTap: ((LoginItem) -> Void)? = nil,
         onSignupTapped: @escaping () -> Void) {
        self.model = model
        self.sessionStore = sessionStore
        self.onTap = onTap
        self.onSignupTapped = onSignupTapped
    }

    var canSubmit: Bool {
        isValidEmail(email) && password.count >= 6 && !isLoading
    }

    func login() async {
        guard canSubmit else { return }
        isLoading = true
        errorMessage = nil
        do {
            try await model.login(email: email.trimmed, password: password)
            me = try await model.fetchCurrentUser()
            await sessionStore.refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func logout() {
        model.deleteToken()
        me = nil
    }

    func toggleSecure() {
        isSecure.toggle()
    }
    
    func onTapSignup() {
        onSignupTapped()
    }
    
    func showTestUsers(message: String) {
        testUsersMessage = message
        showTestUsersAlert = true
    }
    
    func dismissTestUsersAlert() {
        showTestUsersAlert = false
        testUsersMessage = nil
    }

    private func isValidEmail(_ s: String) -> Bool {
        let s = s.trimmingCharacters(in: .whitespacesAndNewlines)
        let regex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return s.range(of: regex, options: [.regularExpression, .caseInsensitive]) != nil
    }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

enum LoginItem {
    case signup
}
