
import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {

    private let model: LoginModel
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isSecure: Bool = true
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var me: [String: Any]?
    
    @Published var showSignup: Bool = false
    @Published var showTestUsersAlert: Bool = false
    @Published var testUsersMessage: String?
    
    init(model: LoginModel = LoginModel()) {
        self.model = model
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
    
    func tapCreateAccount() {
        showSignup = true
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
