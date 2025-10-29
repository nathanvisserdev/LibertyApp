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
    @State private var showSignup = false
    @State private var testUsersMessage: String?
    @State private var showTestUsersAlert = false

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
                        await vm.login()
                        if vm.me != nil {
                            await session.refresh()
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

                // MARK: - Or Divider
                Text("or")
                    .foregroundStyle(.secondary)
                    .font(.callout)

                // MARK: - Create Account Button
                Button {
                    showSignup = true
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
                        testUsersMessage = result.message
                        showTestUsersAlert = true
                    }
                } label: {
                    Text("Create Test Users").font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(24)
            .alert(isPresented: .constant(vm.errorMessage != nil)) {
                Alert(
                    title: Text("Sign-in"),
                    message: Text(vm.errorMessage ?? ""),
                    dismissButton: .default(Text("OK")) { vm.errorMessage = nil }
                )
            }
            .alert("Test Users", isPresented: $showTestUsersAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(testUsersMessage ?? "")
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { hideKeyboard() }
                }
            }
            .sheet(isPresented: $showSignup) {
                SignupFlowView()
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

