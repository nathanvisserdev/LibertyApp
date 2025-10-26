//
//  SignupViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import Foundation
import Combine

@MainActor
final class SignupViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let model: SignupModel
    
    // MARK: - Published
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    @Published var gender: String = "" // MALE, FEMALE, OTHER (required)
    @Published var phoneNumber: String = ""
    @Published var photo: String = ""
    @Published var about: String = ""
    
    @Published var isSecure: Bool = true
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var emailCheckMessage: String?
    @Published var usernameCheckMessage: String?
    
    // MARK: - Init
    init(model: SignupModel = SignupModel()) {
        self.model = model
    }
    
    // MARK: - Computed
    var canSubmit: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        isValidEmail(email) &&
        !username.isEmpty &&
        password.count >= 8 &&
        password == confirmPassword &&
        !isLoading
    }
    
    var passwordsMatch: Bool {
        password == confirmPassword || confirmPassword.isEmpty
    }
    
    var formattedDateOfBirth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: dateOfBirth)
    }
    
    // MARK: - Actions
    func signup() async {
        guard canSubmit else { return }
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            // First, check if email is available
            let emailAvailable = try await model.checkAvailability(email: email.trimmed)
            
            if !emailAvailable {
                errorMessage = "Email already exists. Please use a different email or sign in."
                isLoading = false
                return
            }
            
            // Check if username is available
            let usernameAvailable = try await model.checkAvailability(username: username.trimmed.lowercased())
            
            if !usernameAvailable {
                errorMessage = "Username already exists. Please choose a different username."
                isLoading = false
                return
            }
            
            // If both are available, proceed with signup
            let request = SignupRequest(
                firstName: firstName.trimmed,
                lastName: lastName.trimmed,
                email: email.trimmed,
                username: username.trimmed.lowercased(),
                password: password,
                dateOfBirth: formattedDateOfBirth,
                gender: gender,
                phoneNumber: phoneNumber.trimmed.isEmpty ? nil : phoneNumber.trimmed,
                profilePhoto: photo.trimmed.isEmpty ? nil : photo.trimmed,
                about: about.trimmed.isEmpty ? nil : about.trimmed
            )
            
            try await model.signup(request)
            successMessage = "Account created successfully! You are now logged in."
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func checkEmailAvailability() async {
        guard isValidEmail(email) else {
            emailCheckMessage = nil
            return
        }
        
        do {
            let available = try await model.checkAvailability(email: email.trimmed)
            emailCheckMessage = available ? "✓ Email is available" : "✗ Email already exists"
        } catch {
            emailCheckMessage = nil
        }
    }
    
    func checkUsernameAvailability() async {
        guard !username.isEmpty, username.count >= 3 else {
            usernameCheckMessage = nil
            return
        }
        
        do {
            let available = try await model.checkAvailability(username: username.trimmed.lowercased())
            usernameCheckMessage = available ? "✓ Username is available" : "✗ Username already taken"
        } catch {
            usernameCheckMessage = nil
        }
    }
    
    func toggleSecure() {
        isSecure.toggle()
    }
    
    func clearForm() {
        firstName = ""
        lastName = ""
        email = ""
        username = ""
        password = ""
        confirmPassword = ""
        phoneNumber = ""
        photo = ""
        about = ""
        dateOfBirth = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
        gender = ""
        errorMessage = nil
        successMessage = nil
        emailCheckMessage = nil
        usernameCheckMessage = nil
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
