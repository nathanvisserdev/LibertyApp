//
//  SubnetMenuCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

/// Stateless coordinator for SubnetMenu flow - navigation is SwiftUI-owned
final class SubnetMenuCoordinator {
    
    // MARK: - Init
    init() {
        // Initialize with dependencies if needed
    }
    
    // MARK: - Start
    /// Builds the SubnetMenuView with its ViewModel
    func start() -> some View {
        let viewModel = SubnetMenuViewModel()
        return SubnetMenuView(viewModel: viewModel)
    }
}
