//
//  TabBarCoordinator.swift
//  LibertySocial
//
//  Created by AI Assistant on 2025-10-24.
//

import SwiftUI

/// Stateless coordinator for TabBar - navigation is SwiftUI-owned
final class TabBarCoordinator {
    
    // MARK: - Init
    init() {
        // Initialize with dependencies if needed
    }
    
    // MARK: - Start
    /// Builds the TabBarView with its ViewModel
    func start(onComposeCompleted: @escaping () -> Void) -> some View {
        let viewModel = TabBarViewModel()
        viewModel.onComposeCompleted = onComposeCompleted
        return TabBarView(viewModel: viewModel)
    }
}
