//
//  SignupCredentialsView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import SwiftUI

struct SignupCredentialsView: View {
    @ObservedObject var coordinator: SignupFlowCoordinator
    @State private var confirmPassword: String = ""
    @State private var emailCheckMessage: String = ""
    @State private var isCheckingEmail: Bool = false
    @State private var emailIsValid: Bool? = nil
    @State private var showEmailTakenAlert: Bool = false
    
    private var passwordsMatch: Bool {
        !coordinator.password.isEmpty && coordinator.password == confirmPassword
    }
    
    private var canProceed: Bool {
        !coordinator.email.isEmpty &&
        !coordinator.password.isEmpty &&
        coordinator.password.count >= 8 &&
        passwordsMatch &&
        emailIsValid == true
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Let's get started")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("Step 1 of 7")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.headline)
                
                HStack {
                    TextField("Enter your email", text: $coordinator.email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .onChange(of: coordinator.email) { oldValue, newValue in
                            emailIsValid = nil
                            emailCheckMessage = ""
                            Task {
                                try? await Task.sleep(nanoseconds: 500_000_000)
                                if newValue == coordinator.email {
                                    await checkEmailAvailability()
                                }
                            }
                        }
                    
                    if isCheckingEmail {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else if let valid = emailIsValid {
                        Image(systemName: valid ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(valid ? .green : .red)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(emailIsValid == false ? Color.red : Color.clear, lineWidth: 2)
                )
                
                if !emailCheckMessage.isEmpty {
                    Text(emailCheckMessage)
                        .font(.caption)
                        .foregroundColor(emailIsValid == true ? .green : .red)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.headline)
                
                SecureField("At least 8 characters", text: $coordinator.password)
                    .textContentType(.newPassword)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                if !coordinator.password.isEmpty && coordinator.password.count < 8 {
                    Text("Password must be at least 8 characters")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm Password")
                    .font(.headline)
                
                HStack {
                    SecureField("Re-enter your password", text: $confirmPassword)
                        .textContentType(.newPassword)
                        .autocorrectionDisabled()
                    
                    if !coordinator.password.isEmpty && !confirmPassword.isEmpty {
                        Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(passwordsMatch ? .green : .red)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                if !confirmPassword.isEmpty && !passwordsMatch {
                    Text("Passwords don't match")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Spacer()
            
            Button(action: {
                // Extra safeguard: verify email is available before proceeding
                if emailIsValid == false {
                    showEmailTakenAlert = true
                    return
                }
                
                guard emailIsValid == true else {
                    emailCheckMessage = "Please wait for email validation to complete"
                    return
                }
                
                coordinator.nextStep()
            }) {
                Text("Continue")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canProceed ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(!canProceed)
            .padding(.bottom, 20)
        }
        .padding(.horizontal)
        .alert("Email Already Exists", isPresented: $showEmailTakenAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This email is already registered. Please use a different email or sign in to your existing account.")
        }
    }
    
    private func checkEmailAvailability() async {
        let trimmedEmail = coordinator.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        guard !trimmedEmail.isEmpty else {
            emailCheckMessage = ""
            emailIsValid = nil
            return
        }
        
        print("📧 Checking email availability for: '\(trimmedEmail)'")
        isCheckingEmail = true
        
        do {
            let model = SignupModel()
            let isAvailable = try await model.checkAvailability(email: trimmedEmail)
            
            print("📧 Email '\(trimmedEmail)' availability result: \(isAvailable)")
            
            if isAvailable {
                emailCheckMessage = "Email is available"
                emailIsValid = true
            } else {
                emailCheckMessage = "Email is already taken"
                emailIsValid = false
            }
        } catch {
            print("❌ Email availability check failed: \(error)")
            emailCheckMessage = "Could not verify email"
            emailIsValid = nil
        }
        
        isCheckingEmail = false
    }
}
