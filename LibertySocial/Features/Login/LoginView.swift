//
//  LoginView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-06.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var vm = LoginViewModel()
    @EnvironmentObject private var session: SessionStore

    // Computed so it can capture `session`
    var onLogin: (String, String) async throws -> Void {
        { email, password in
            let token = try await AuthService.login(email: email, password: password)
            try? KeychainHelper.save(token: token)
            session.refresh() // trigger UI switch to MainView
            print("🔐 Saved token to Keychain")
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                HStack(spacing: 1) {
                    Image("liberty_bell")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                    Text("Liberty Social").font(.largeTitle.bold())
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Welcome back").font(.largeTitle.bold())
                    Text("Sign in with your email").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

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
                        Button { withAnimation(.snappy) { vm.isSecure.toggle() } } label: {
                            Image(systemName: vm.isSecure ? "eye" : "eye.slash").imageScale(.medium)
                        }
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 14).strokeBorder(.separator))

                    HStack {
                        Button("Create account") {
                            Task { try? await AuthService.signup(email: vm.email, password: vm.password) }
                        }
                        Spacer()
                        Button("Forgot password?") {}
                    }
                    .font(.callout)
                }

                Button(action: { Task { await vm.submit(authenticate: onLogin) } }) {
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
                Alert(title: Text("Sign-in failed"),
                      message: Text(vm.errorMessage ?? ""),
                      dismissButton: .default(Text("OK")) { vm.errorMessage = nil })
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
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
#endif

#Preview { LoginView().tint(.blue) }

