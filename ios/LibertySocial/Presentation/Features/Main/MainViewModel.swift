//
//  MainViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-07.
//

import Foundation
import Combine

@MainActor
final class MainViewModel: ObservableObject {
    @Published var welcomeMessage = "Welcome to Liberty Social"
    @Published var meResult: String?

    func refreshGreeting() {
        welcomeMessage = "Welcome back!"
    }

    func logout(using session: SessionStore) {
        session.logout()
    }

    func loadMe() async {
        do {
            let me = try await AuthService.shared.fetchCurrentUser()
            let id = me["id"] as? String ?? "unknown"
            let email = me["email"] as? String ?? "unknown"
            meResult = "id=\(id), email=\(email)"
        } catch {
            meResult = "Error: \((error as NSError).localizedDescription)"
        }
    }
}


