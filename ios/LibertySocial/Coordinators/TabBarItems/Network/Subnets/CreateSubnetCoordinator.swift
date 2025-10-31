//
//  CreateSubnetCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

/// Stateless coordinator for CreateSubnet flow - navigation is SwiftUI-owned
final class CreateSubnetCoordinator {
    
    private let onSubnetCreated: () -> Void
    
    // MARK: - Init
    init(onSubnetCreated: @escaping () -> Void = {}) {
        self.onSubnetCreated = onSubnetCreated
    }
    
    // MARK: - Start
    /// Builds the CreateSubnetView with its ViewModel
    func start() -> some View {
        let viewModel = CreateSubnetViewModel(onSubnetCreated: onSubnetCreated)
        return CreateSubnetView(viewModel: viewModel)
    }
}
