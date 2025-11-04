//
//  LoginCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

/// Stateless coordinator for Login flow - navigation is SwiftUI-owned
final class LoginCoordinator {

    init() {
        // Initialize with dependencies if needed
    }
    
    /// Builds the LoginView with its ViewModel
    func start() -> some View {
        let viewModel = LoginViewModel()
        return LoginView(viewModel: viewModel)
    }
}
