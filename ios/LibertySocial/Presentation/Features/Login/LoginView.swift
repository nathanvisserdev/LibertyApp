//
//  LoginView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-06.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @EnvironmentObject private var session: SessionStore
    
    init(viewModel: LoginViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

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
                    TextField("you@example.com", text: $viewModel.email)
                        .textContentType(.username)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .submitLabel(.next)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 14).strokeBorder(.separator))

                    HStack {
                        Group {
                            if viewModel.isSecure {
                                SecureField("Password", text: $viewModel.password)
                                    .textContentType(.password)
                            } else {
                                TextField("Password", text: $viewModel.password)
                                    .textContentType(.password)
                            }
                        }
                        Button { withAnimation(.snappy) { viewModel.toggleSecure() } } label: {
                            Image(systemName: viewModel.isSecure ? "eye" : "eye.slash")
                                .imageScale(.medium)
                        }
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 14).strokeBorder(.separator))

                    // MARK: - Forgot Password
                    HStack {
                        Spacer()
                        Button("Forgot password?") {}
                    }
                    .font(.callout)
                }

                // MARK: - Sign-in Button
                Button {
                    Task {
                        await viewModel.login()
                        if viewModel.me != nil {
                            await session.refresh()
                        }
                    }
                } label: {
                    if viewModel.isLoading { ProgressView().controlSize(.small) }
                    else { Text("Sign in").font(.headline) }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!viewModel.canSubmit)
                .frame(maxWidth: .infinity)

                // MARK: - Or Divider
                Text("or")
                    .foregroundStyle(.secondary)
                    .font(.callout)

                // MARK: - Create Account Button
                Button {
                    viewModel.tapCreateAccount()
                } label: {
                    Text("Create account").font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)

                Spacer(minLength: 0)
                
                // MARK: - Test Users Button (Development Only)
                Button {
                    Task {
                        let result = await CreateTestUsers.createAllUsers()
                        viewModel.showTestUsers(message: result.message)
                    }
                } label: {
                    Text("Create Test Users").font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(24)
            .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
                Alert(
                    title: Text("Sign-in"),
                    message: Text(viewModel.errorMessage ?? ""),
                    dismissButton: .default(Text("OK")) { viewModel.errorMessage = nil }
                )
            }
            .alert(
                "Test Users",
                isPresented: $viewModel.showTestUsersAlert
            ) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.testUsersMessage ?? "")
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { hideKeyboard() }
                }
            }
            .sheet(isPresented: $viewModel.showSignup) {
                SignupCoordinator().start()
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
    LoginView(viewModel: LoginViewModel()).tint(.blue)
}

