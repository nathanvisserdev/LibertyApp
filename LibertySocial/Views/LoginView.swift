//
//  LoginView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-06.
//

import SwiftUI

// MARK: - LoginView
struct LoginView: View {
    @StateObject private var vm = LoginViewModel()

    /// Inject your real authentication later (REST, Firebase, etc.)
    var onLogin: (String, String) async throws -> Void = { email, password in
        // Demo auth: simulate delay and fake validation
        try await Task.sleep(nanoseconds: 700_000_000)
        guard email.lowercased().hasSuffix("@example.com"), password.count >= 6 else {
            struct AuthError: LocalizedError { var errorDescription: String? { "Invalid email or password" } }
            throw AuthError()
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                HStack(spacing:1) {
                    Image("liberty_bell")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                    Text("Liberty Social")
                        .font(.largeTitle.bold())
                    Spacer()
                }

                // MARK: - Header (top of the screen)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Welcome back")
                        .font(.largeTitle.bold())
                    Text("Sign in with your email")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // MARK: - Form Fields
                VStack(spacing: 14) {
                    // Email
                    TextField("you@example.com", text: $vm.email)
                        .textContentType(.username)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .submitLabel(.next)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 14).strokeBorder(.separator))

                    // Password + visibility toggle
                    HStack {
                        Group {
                            if vm.isSecure {
                                SecureField("Password", text: $vm.password)
                                    .textContentType(.password)
                            } else {
                                TextField("Password", text: $vm.password)
                                    .textContentType(.password)
                            }
                        }
                        Button {
                            withAnimation(.snappy) { vm.isSecure.toggle() }
                        } label: {
                            Image(systemName: vm.isSecure ? "eye" : "eye.slash")
                                .imageScale(.medium)
                                .accessibilityLabel(vm.isSecure ? "Show password" : "Hide password")
                        }
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 14).strokeBorder(.separator))

                    // Forgot / Create account
                    HStack {
                        Button("Create account") {}
                        Spacer()
                        Button("Forgot password?") {}
                    }
                    .font(.callout)
                }

                // MARK: - Submit Button
                Button(action: { Task { await vm.submit(authenticate: onLogin) } }) {
                    if vm.isLoading {
                        ProgressView().controlSize(.small)
                    } else {
                        Text("Sign in")
                            .font(.headline)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!vm.canSubmit)
                .frame(maxWidth: .infinity)

                Spacer(minLength: 0)
            }
            .padding(24)

            // MARK: - Alerts & Keyboard Toolbar
            .alert(isPresented: .constant(vm.errorMessage != nil)) {
                Alert(
                    title: Text("Sign-in failed"),
                    message: Text(vm.errorMessage ?? ""),
                    dismissButton: .default(Text("OK")) {
                        vm.errorMessage = nil
                    }
                )
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { hideKeyboard() }
                }
            }
        }
    }
}

// MARK: - Helpers
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
#endif

// MARK: - Preview
#Preview {
    LoginView()
        .tint(.blue)
}

