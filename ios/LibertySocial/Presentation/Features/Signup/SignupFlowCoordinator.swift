//
//  SignupFlowCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import SwiftUI
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
final class SignupFlowCoordinator: ObservableObject {
    @Published var currentStep: SignupStep = .credentials
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var username: String = ""
    @Published var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    @Published var gender: String = "PREFER_NOT_TO_SAY"
    @Published var photo: String = ""
    @Published var about: String = ""
    @Published var phoneNumber: String = ""
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showWelcome: Bool = false
    
    func nextStep() {
        if let next = SignupStep(rawValue: currentStep.rawValue + 1) {
            currentStep = next
        }
    }
    
    func skipToComplete() {
        currentStep = .complete
        showWelcome = true
    }
    
    func completeSignup() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            let request = SignupRequest(
                firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                username: username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                password: password,
                dateOfBirth: formatter.string(from: dateOfBirth),
                gender: gender,
                phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
                photo: photo.isEmpty ? nil : photo.trimmingCharacters(in: .whitespacesAndNewlines),
                about: about.isEmpty ? nil : about.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            try await AuthService.signup(request)
            
            // Auto-login after signup
            _ = try await AuthService.login(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
            
            // Successfully signed up - no error
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
