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

    func refreshGreeting() {
        // placeholder for future logic, e.g. fetch user profile or feed
        welcomeMessage = "Welcome back!"
    }

    func logout(using session: SessionStore) {
        session.logout()
    }
}

