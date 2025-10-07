//
//  LoginViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-06.
//

import Foundation
import Combine

// MARK: - LoginViewModel
@MainActor
final class LoginViewModel: ObservableObject {
    
    init() {
        print("Login view model initialized")
    }
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isSecure: Bool = true
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Computed Properties
    var canSubmit: Bool {
        isValidEmail(email) && password.count >= 6 && !isLoading
    }

    // MARK: - Actions
    func submit(authenticate: @escaping (String, String) async throws -> Void) async {
        guard canSubmit else { return }

        isLoading = true
        errorMessage = nil

        do {
            try await authenticate(email.trimmingCharacters(in: .whitespacesAndNewlines), password)
        } catch {
            errorMessage = (error as NSError).localizedDescription
        }

        isLoading = false
    }

    // MARK: - Validation
    private func isValidEmail(_ s: String) -> Bool {
        let s = s.trimmingCharacters(in: .whitespacesAndNewlines)
        let regex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return s.range(of: regex, options: [.regularExpression, .caseInsensitive]) != nil
    }
}

