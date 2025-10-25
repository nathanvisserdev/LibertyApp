//
//  SignupView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import SwiftUI

struct SignupView: View {
    @StateObject private var vm = SignupViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Create Account")
                            .font(.largeTitle.bold())
                        Text("Fill in your information to get started")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // MARK: - Input Fields
                    VStack(spacing: 14) {
                        // First Name
                        TextField("First Name", text: $vm.firstName)
                            .textContentType(.givenName)
                            .autocorrectionDisabled()
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 14).strokeBorder(.separator))
                        
                        // Last Name
                        TextField("Last Name", text: $vm.lastName)
                            .textContentType(.familyName)
                            .autocorrectionDisabled()
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 14).strokeBorder(.separator))
                        
                        // Email
                        VStack(alignment: .leading, spacing: 4) {
                            TextField("Email", text: $vm.email)
                                .textContentType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                .onChange(of: vm.email) { _, _ in
                                    vm.emailCheckMessage = nil
                                    Task {
                                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second debounce
                                        await vm.checkEmailAvailability()
                                    }
                                }
                                .padding(14)
                                .background(RoundedRectangle(cornerRadius: 14).strokeBorder(.separator))
                            
                            if let message = vm.emailCheckMessage {
                                Text(message)
                                    .font(.caption)
                                    .foregroundStyle(message.hasPrefix("✓") ? .green : .red)
                            }
                        }
                        
                        // Username
                        VStack(alignment: .leading, spacing: 4) {
                            TextField("Username", text: $vm.username)
                                .textContentType(.username)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .onChange(of: vm.username) { _, _ in
                                    vm.usernameCheckMessage = nil
                                    Task {
                                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second debounce
                                        await vm.checkUsernameAvailability()
                                    }
                                }
                                .padding(14)
                                .background(RoundedRectangle(cornerRadius: 14).strokeBorder(.separator))
                            
                            if let message = vm.usernameCheckMessage {
                                Text(message)
                                    .font(.caption)
                                    .foregroundStyle(message.hasPrefix("✓") ? .green : .red)
                            }
                        }
                        
                        // Password
                        HStack {
                            Group {
                                if vm.isSecure {
                                    SecureField("Password (min 8 characters)", text: $vm.password)
                                        .textContentType(.newPassword)
                                        .autocorrectionDisabled()
                                } else {
                                    TextField("Password (min 8 characters)", text: $vm.password)
                                        .textContentType(.newPassword)
                                        .autocorrectionDisabled()
                                }
                            }
                            Button { withAnimation(.snappy) { vm.toggleSecure() } } label: {
                                Image(systemName: vm.isSecure ? "eye" : "eye.slash")
                                    .imageScale(.medium)
                            }
                        }
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 14).strokeBorder(.separator))
                        
                        // Confirm Password
                        HStack {
                            Group {
                                if vm.isSecure {
                                    SecureField("Confirm Password", text: $vm.confirmPassword)
                                        .textContentType(.newPassword)
                                        .autocorrectionDisabled()
                                } else {
                                    TextField("Confirm Password", text: $vm.confirmPassword)
                                        .textContentType(.newPassword)
                                        .autocorrectionDisabled()
                                }
                            }
                            if !vm.confirmPassword.isEmpty {
                                Image(systemName: vm.passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(vm.passwordsMatch ? .green : .red)
                            }
                        }
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 14).strokeBorder(
                            vm.passwordsMatch ? Color.gray.opacity(0.3) : Color.red
                        ))
                        
                        // Date of Birth
                        DatePicker(
                            "Date of Birth",
                            selection: $vm.dateOfBirth,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 14).strokeBorder(.separator))
                        
                        // Gender
                        Picker("Gender", selection: $vm.gender) {
                            Text("Male").tag("MALE")
                            Text("Female").tag("FEMALE")
                            Text("Other").tag("OTHER")
                            Text("Prefer not to say").tag("PREFER_NOT_TO_SAY")
                        }
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 14).strokeBorder(.separator))
                        
                        // MARK: - Optional Fields Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Optional Information")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            // Phone Number
                            TextField("Phone Number (optional)", text: $vm.phoneNumber)
                                .textContentType(.telephoneNumber)
                                .keyboardType(.phonePad)
                                .padding(14)
                                .background(RoundedRectangle(cornerRadius: 14).strokeBorder(.separator))
                            
                            // About
                            TextField("About (optional)", text: $vm.about, axis: .vertical)
                                .lineLimit(3...5)
                                .padding(14)
                                .background(RoundedRectangle(cornerRadius: 14).strokeBorder(.separator))
                        }
                    }
                    
                    // MARK: - Create Account Button
                    Button {
                        Task {
                            await vm.signup()
                            if vm.successMessage != nil {
                                // Wait a moment to show success message, then dismiss
                                try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
                                dismiss()
                            }
                        }
                    } label: {
                        if vm.isLoading {
                            ProgressView().controlSize(.small)
                        } else {
                            Text("Create Account").font(.headline)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!vm.canSubmit)
                    .frame(maxWidth: .infinity)
                    
                    // Already have account
                    Button("Already have an account? Sign in") {
                        dismiss()
                    }
                    .font(.callout)
                }
                .padding(24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { hideKeyboard() }
                }
            }
            .alert(isPresented: .constant(vm.errorMessage != nil)) {
                Alert(
                    title: Text("Sign Up Error"),
                    message: Text(vm.errorMessage ?? ""),
                    dismissButton: .default(Text("OK")) { vm.errorMessage = nil }
                )
            }
            .alert(isPresented: .constant(vm.successMessage != nil)) {
                Alert(
                    title: Text("Success!"),
                    message: Text(vm.successMessage ?? ""),
                    dismissButton: .default(Text("OK")) { vm.successMessage = nil }
                )
            }
        }
    }
}

#Preview {
    SignupView()
}
