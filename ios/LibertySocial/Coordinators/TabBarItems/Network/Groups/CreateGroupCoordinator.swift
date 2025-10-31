//
//  CreateGroupCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

/// Stateless coordinator for CreateGroup flow - navigation is SwiftUI-owned
final class CreateGroupCoordinator {
    
    private let authSession: AuthSession
    private let authService: AuthServiceProtocol
    
    // MARK: - Init
    init(authSession: AuthSession = AuthService.shared, authService: AuthServiceProtocol = AuthService.shared) {
        self.authSession = authSession
        self.authService = authService
    }
    
    // MARK: - Start
    /// Builds the CreateGroupView with its ViewModel
    func start() -> some View {
        let model = CreateGroupModel(authSession: authSession, authService: authService)
        let viewModel = CreateGroupViewModel(model: model)
        return CreateGroupView(viewModel: viewModel)
    }
}
