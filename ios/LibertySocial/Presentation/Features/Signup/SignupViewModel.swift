//
//  SignupViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import Foundation
import Combine

enum SignupStep: Int, CaseIterable {
    case credentials = 0
    case name = 1
    case username = 2
    case demographics = 3
    case photo = 4
    case about = 5
    case phone = 6
    case complete = 7
}

@MainActor
final class SignupViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let model: SignupModel
    
    // MARK: - Flow State
    @Published var currentStep: SignupStep = .credentials
    
    // MARK: - Form Fields
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    @Published var gender: String = "MALE"
    @Published var isPrivate: Bool = true
    @Published var phoneNumber: String = ""
    @Published var photo: String = ""
    @Published var about: String = ""
    
    // Store photo data temporarily until after signup
    @Published var photoData: Data?
    
    // MARK: - UI State
    @Published var isSecure: Bool = true
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var emailCheckMessage: String?
    @Published var usernameCheckMessage: String?
    @Published var showWelcome: Bool = false
    @Published var photoUploadSuccess: Bool = false
    @Published var photoUploadMessage: String?
    
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
    
    // MARK: - Navigation
    func nextStep() {
        if let next = SignupStep(rawValue: currentStep.rawValue + 1) {
            currentStep = next
        }
    }
    
    func skipToComplete() {
        currentStep = .complete
        showWelcome = true
    }
    
    // MARK: - Actions
    
    /// Complete the multi-step signup flow
    func completeSignup() async {
        print("🚀 completeSignup: Starting signup process...")
        print("🚀 completeSignup: Has photo data? \(photoData != nil)")
        if let photoData = photoData {
            print("🚀 completeSignup: Photo data size: \(photoData.count) bytes")
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Check if we have photo data - it's now required
            guard photoData != nil else {
                errorMessage = "Profile photo is required. Please select a photo."
                isLoading = false
                return
            }
            
            // Use a placeholder URL for now - we'll upload the real photo after signup
            let placeholderPhotoURL = "https://placeholder.com/profile-photo-pending"
            
            let request = SignupRequest(
                firstName: firstName.trimmed,
                lastName: lastName.trimmed,
                email: email.trimmed,
                username: username.trimmed.lowercased(),
                password: password,
                dateOfBirth: formattedDateOfBirth,
                gender: gender,
                isPrivate: isPrivate,
                phoneNumber: phoneNumber.trimmed.isEmpty ? nil : phoneNumber.trimmed,
                profilePhoto: placeholderPhotoURL,
                about: about.trimmed.isEmpty ? nil : about.trimmed
            )
            
            print("📝 completeSignup: Calling signup endpoint...")
            try await model.signup(request)
            print("✅ completeSignup: Signup successful!")
            
            // Auto-login is now handled by SignupModel (token is saved)
            print("✅ completeSignup: User is now logged in!")
            
            // Now upload the actual photo since we have a token
            if let photoData = photoData {
                do {
                    print("📸 completeSignup: Starting photo upload with \(photoData.count) bytes...")
                    let photoKey = try await model.uploadPhoto(photoData: photoData)
                    photo = photoKey
                    photoUploadSuccess = true
                    photoUploadMessage = "Profile photo uploaded successfully! ✓"
                    print("✅ completeSignup: Photo upload completed successfully")
                } catch {
                    print("❌ completeSignup: Photo upload failed!")
                    print("❌ completeSignup: Error: \(error)")
                    print("❌ completeSignup: Error description: \(error.localizedDescription)")
                    
                    if let nsError = error as NSError? {
                        print("❌ completeSignup: Error domain: \(nsError.domain)")
                        print("❌ completeSignup: Error code: \(nsError.code)")
                        print("❌ completeSignup: Error userInfo: \(nsError.userInfo)")
                    }
                    
                    photoUploadSuccess = false
                    photoUploadMessage = "Photo upload failed, but your account was created. You can upload a photo later."
                    // Don't fail signup if photo upload fails
                }
            }
            
            // Successfully signed up - no error
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Single-step signup (for standalone SignupView)
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
                isPrivate: isPrivate,
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
        photoData = nil
        dateOfBirth = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
        gender = "MALE"
        isPrivate = true
        errorMessage = nil
        successMessage = nil
        emailCheckMessage = nil
        usernameCheckMessage = nil
        photoUploadSuccess = false
        photoUploadMessage = nil
        currentStep = .credentials
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
