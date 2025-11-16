
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
    private let model: SignupModel
    private let sessionStore: SessionStore
    private let onNextStep: (NextView) -> Void
    private let onSignupComplete: () -> Void
    
    @Published var currentStep: SignupStep = .credentials
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
    @Published var photoData: Data?
    @Published var isSecure: Bool = true
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var emailCheckMessage: String?
    @Published var usernameCheckMessage: String?
    @Published var showWelcome: Bool = false
    @Published var photoUploadSuccess: Bool = false
    @Published var photoUploadMessage: String?
    
    init(model: SignupModel, sessionStore: SessionStore, onNextStep: @escaping (NextView) -> Void, onSignupComplete: @escaping () -> Void) {
        self.model = model
        self.sessionStore = sessionStore
        self.onNextStep = onNextStep
        self.onSignupComplete = onSignupComplete
    }
    
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
    
    func nextStep(_ nextView: NextView) {
        if let next = SignupStep(rawValue: currentStep.rawValue + 1) {
            currentStep = next
        }
        onNextStep(nextView)
    }
    
    func cancelSignup() {
        onSignupComplete()
    }
    
    func skipToComplete() {
        currentStep = .complete
        showWelcome = true
    }
    
    
    func completeSignup() async {
        isLoading = true
        errorMessage = nil
        do {
            guard photoData != nil else {
                errorMessage = "Profile photo is required. Please select a photo."
                isLoading = false
                return
            }
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
            try await model.signup(request)
            if let photoData = photoData {
                do {
                    let photoKey = try await model.uploadPhoto(photoData: photoData)
                    photo = photoKey
                    photoUploadSuccess = true
                    photoUploadMessage = "Profile photo uploaded successfully! ✓"
                } catch {
                    photoUploadSuccess = false
                    photoUploadMessage = "Photo upload failed, but your account was created. You can upload a photo later."
                }
            }
            nextStep(.complete)
//            onSignupComplete()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signup() async {
        guard canSubmit else { return }
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let emailAvailable = try await model.checkAvailability(email: email.trimmed)
            
            if !emailAvailable {
                errorMessage = "Email already exists. Please use a different email or sign in."
                isLoading = false
                return
            }
            
            let usernameAvailable = try await model.checkAvailability(username: username.trimmed.lowercased())
            
            if !usernameAvailable {
                errorMessage = "Username already exists. Please choose a different username."
                isLoading = false
                return
            }
            
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
    
    func refreshSession() async {
        await sessionStore.refresh()
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
    
    private func isValidEmail(_ s: String) -> Bool {
        let s = s.trimmingCharacters(in: .whitespacesAndNewlines)
        let regex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return s.range(of: regex, options: [.regularExpression, .caseInsensitive]) != nil
    }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
