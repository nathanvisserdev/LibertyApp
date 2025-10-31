//
//  GroupsMenuCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

/// Stateless coordinator for GroupsMenu flow - navigation is SwiftUI-owned
final class GroupsMenuCoordinator {
    
    // MARK: - Init
    init() {
        // Initialize with dependencies if needed
    }
    
    // MARK: - Start
    /// Builds the GroupsMenuView with its ViewModel
    func start() -> some View {
        let viewModel = GroupsMenuViewModel()
        return GroupsMenuView(viewModel: viewModel)
    }
}
