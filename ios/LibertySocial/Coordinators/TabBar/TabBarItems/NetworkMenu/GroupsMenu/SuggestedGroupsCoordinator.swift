//
//  SuggestedGroupsCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

/// Stateless coordinator for SuggestedGroups flow - navigation is SwiftUI-owned
final class SuggestedGroupsCoordinator {
    
    private let TokenProvider: TokenProviding
    private let AuthManager: AuthManaging
    
    // MARK: - Init
    init(TokenProvider: TokenProviding = AuthService.shared, AuthManager: AuthManaging = AuthService.shared) {
        self.TokenProvider = TokenProvider
        self.AuthManager = AuthManager
    }
    
    // MARK: - Start
    /// Builds the SuggestedGroupsView with its ViewModel
    func start(onDismiss: @escaping () -> Void, onSelect: @escaping (UserGroup) -> Void) -> some View {
        let model = SuggestedGroupsModel(TokenProvider: TokenProvider, AuthManager: AuthManager)
        let viewModel = SuggestedGroupsViewModel(model: model)
        
        // Set up callbacks
        viewModel.onDismiss = {
            onDismiss()
        }
        viewModel.onGroupSelected = { group in
            onSelect(group)
        }
        
        return SuggestedGroupsView(viewModel: viewModel)
    }
}
