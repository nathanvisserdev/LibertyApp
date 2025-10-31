//
//  CreateSubnetCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

/// Stateless coordinator for CreateSubnet flow - navigation is SwiftUI-owned
final class CreateSubnetCoordinator {
    
    // MARK: - Init
    init() {
        // Initialize with dependencies if needed
    }
    
    // MARK: - Start
    /// Builds the CreateSubnetView with its ViewModel
    func start() -> some View {
        let viewModel = CreateSubnetViewModel()
        return CreateSubnetView(viewModel: viewModel)
    }
}
