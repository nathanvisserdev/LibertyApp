//
//  GroupCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

/// Stateless coordinator for Group detail flow - navigation is SwiftUI-owned
final class GroupCoordinator {
    
    private let TokenProvider: TokenProviding
    private let AuthManager: AuthManaging
    private let group: UserGroup
    
    // MARK: - Init
    init(group: UserGroup, TokenProvider: TokenProviding = AuthService.shared, AuthManager: AuthManaging = AuthService.shared) {
        self.group = group
        self.TokenProvider = TokenProvider
        self.AuthManager = AuthManager
    }
    
    // MARK: - Start
    /// Builds the GroupView with its ViewModel
    func start() -> some View {
        let model = GroupModel(TokenProvider: TokenProvider, AuthManager: AuthManager)
        let viewModel = GroupViewModel(group: group, model: model)
        return GroupView(group: group, viewModel: viewModel)
    }
}
