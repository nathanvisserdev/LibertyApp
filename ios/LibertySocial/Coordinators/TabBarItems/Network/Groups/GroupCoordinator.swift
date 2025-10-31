//
//  GroupCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

/// Stateless coordinator for Group detail flow - navigation is SwiftUI-owned
final class GroupCoordinator {
    
    private let authSession: AuthSession
    private let authService: AuthServiceProtocol
    private let group: UserGroup
    
    // MARK: - Init
    init(group: UserGroup, authSession: AuthSession = AuthService.shared, authService: AuthServiceProtocol = AuthService.shared) {
        self.group = group
        self.authSession = authSession
        self.authService = authService
    }
    
    // MARK: - Start
    /// Builds the GroupView with its ViewModel
    func start() -> some View {
        let model = GroupModel(authSession: authSession, authService: authService)
        let viewModel = GroupViewModel(group: group, model: model)
        return GroupView(group: group, viewModel: viewModel)
    }
}
