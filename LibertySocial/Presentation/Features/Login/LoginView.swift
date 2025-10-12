//
//  LoginView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-06.
//

import SwiftUI
import Combine

struct LoginView: View {
    @StateObject private var vm = LoginViewModel()
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // MARK: - Header
                HStack(spacing: 1) {
                    Image("liberty_bell")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                    Text("Liberty Social")
                        .font(.largeTitle.bold())
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Welcome back")
                        .font(.largeTitle.bold())
                    Text("Sign in with your email")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // MARK: - Input Fields
                VStack(spacing: 14) {
                    TextField("you@example.com", text: $vm.email)
                        .textContentType(.username)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .submitLabel(.next)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 14).strokeBorder(.separator))

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
                        Button { withAnimation(.snappy) { vm.toggleSecure() } } label: {
                            Image(systemName: vm.isSecure ? "eye" : "eye.slash")
                                .imageScale(.medium)
                        }
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 14).strokeBorder(.separator))

                    // MARK: - Signup and Forgot Password
                    HStack {
                        Button("Create account") {
                            Task {
                                do {
                                    let req = SignupRequest(
                                        firstName: "Nathan",
                                        lastName: "Visser",
                                        email: vm.email,
                                        username: vm.email.components(separatedBy: "@").first ?? "user",
                                        password: vm.password,
                                        dateOfBirth: "1990-01-01",
                                        gender: true
                                    )
                                    try await AuthService.signup(req)
                                    vm.errorMessage = "Account created! Please sign in."
                                } catch {
                                    vm.errorMessage = error.localizedDescription
                                }
                            }
                        }
                        Spacer()
                        Button("Forgot password?") {}
                    }
                    .font(.callout)
                }

                // MARK: - Sign-in Button
                Button {
                    Task {
                        await vm.login()
                        if vm.me != nil {
                            session.refresh() // Move user to main app view
                        }
                    }
                } label: {
                    if vm.isLoading { ProgressView().controlSize(.small) }
                    else { Text("Sign in").font(.headline) }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!vm.canSubmit)
                .frame(maxWidth: .infinity)

                Spacer(minLength: 0)
            }
            .padding(24)
            .alert(isPresented: .constant(vm.errorMessage != nil)) {
                Alert(
                    title: Text("Sign-in"),
                    message: Text(vm.errorMessage ?? ""),
                    dismissButton: .default(Text("OK")) { vm.errorMessage = nil }
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

#Preview {
    LoginView().tint(.blue)
}

