//
//  LoginPage.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-02.
//

import SwiftUI
import Combine

// MARK: - LoginViewModel

/*
@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isSecure: Bool = true
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    var canSubmit: Bool {
        isValidEmail(email) && password.count >= 6 && !isLoading
    }

    func submit(authenticate: @escaping (String, String) async throws -> Void) async {
        guard canSubmit else { return }
        isLoading = true
        errorMessage = nil
        do {
            try await authenticate(email.trimmingCharacters(in: .whitespacesAndNewlines), password)
        } catch {
            errorMessage = (error as NSError).localizedDescription
        }
        isLoading = false
    }

    // Simple but practical email validator (RFC-lite)
    private func isValidEmail(_ s: String) -> Bool {
        let s = s.trimmingCharacters(in: .whitespacesAndNewlines)
        let regex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return s.range(of: regex, options: [.regularExpression, .caseInsensitive]) != nil
    }
}

// MARK: - LoginView
struct LoginView: View {
    @StateObject private var vm = LoginViewModel()

    /// Inject your real auth here. Throw to surface an error toast.
    var onLogin: (String, String) async throws -> Void = { email, password in
        // Demo fake auth
        try await Task.sleep(nanoseconds: 700_000_000)
        guard email.lowercased().hasSuffix("@example.com"), password.count >= 6 else {
            struct AuthError: LocalizedError { var errorDescription: String? { "Invalid email or password" } }
            throw AuthError()
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Title
                VStack(alignment: .leading, spacing: 6) {
                    Text("Welcome back")
                        .font(.largeTitle.bold())
                    Text("Sign in with your email")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Form
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

                    // Password
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

                    // Forgot / Create
                    HStack {
                        Button("Create account") {}
                        Spacer()
                        Button("Forgot password?") {}
                    }
                    .font(.callout)
                }

                // Sign in button
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
            .navigationTitle("Sign in")
            .alert(isPresented: .constant(vm.errorMessage != nil)) {
                Alert(title: Text("Sign-in failed"), message: Text(vm.errorMessage ?? ""), dismissButton: .default(Text("OK")) { vm.errorMessage = nil })
            }
            .toolbar { ToolbarItemGroup(placement: .keyboard) { Spacer(); Button("Done") { hideKeyboard() } } }
        }
    }
}

// MARK: - Helpers
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

// MARK: - Preview
#Preview {
    LoginView()
        .tint(.blue)
}

/*
INTEGRATION NOTES
-----------------
1) Drop this file into your SwiftUI project (iOS 16+).
2) Present LoginView() wherever appropriate, injecting your real auth function, e.g.:

struct ContentView: View {
    @State private var isAuthed = false
    var body: some View {
        if isAuthed {
            MainAppView()
        } else {
            LoginView(onLogin: { email, password in
                // Replace with your real call (FirebaseAuth, Supabase, custom backend, etc.)
                try await AuthService.shared.signIn(email: email, password: password)
                isAuthed = true
            })
        }
    }
}

3) Replace the demo onLogin with your backend logic. Throw to surface an error alert.
4) UI/UX niceties: the button disables until email+password are valid, includes progress state, and password visibility toggle.
*/
*/
