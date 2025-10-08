//
//  LoginViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-06.
//

import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {

    // MARK: - Published
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isSecure: Bool = true
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var me: [String: Any]?    // now a dictionary instead of MeResponse

    // MARK: - Computed
    var canSubmit: Bool {
        isValidEmail(email) && password.count >= 6 && !isLoading
    }

    // MARK: - Actions
    func login() async {
        guard canSubmit else { return }
        isLoading = true
        errorMessage = nil
        do {
            _ = try await AuthService.login(email: email.trimmed, password: password)
            me = try await AuthService.fetchCurrentUser()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func logout() {
        AuthService.logout()
        me = nil
    }

    func toggleSecure() {
        isSecure.toggle()
    }

    // MARK: - Validation
    private func isValidEmail(_ s: String) -> Bool {
        let s = s.trimmingCharacters(in: .whitespacesAndNewlines)
        let regex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return s.range(of: regex, options: [.regularExpression, .caseInsensitive]) != nil
    }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
