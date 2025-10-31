//
//  SuggestedGroupsCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

/// Stateless coordinator for SuggestedGroups flow - navigation is SwiftUI-owned
final class SuggestedGroupsCoordinator {
    
    private let authSession: AuthSession
    private let authService: AuthServiceProtocol
    
    // MARK: - Init
    init(authSession: AuthSession = AuthService.shared, authService: AuthServiceProtocol = AuthService.shared) {
        self.authSession = authSession
        self.authService = authService
    }
    
    // MARK: - Start
    /// Builds the SuggestedGroupsView with its ViewModel
    func start() -> some View {
        let model = SuggestedGroupsModel(authSession: authSession, authService: authService)
        let viewModel = SuggestedGroupsViewModel(model: model)
        return SuggestedGroupsView(viewModel: viewModel)
    }
}
