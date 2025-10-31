//
//  ConnectionsCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

/// Stateless coordinator for Connections flow - navigation is SwiftUI-owned
final class ConnectionsCoordinator {
    
    // MARK: - Init
    init() {
        // Initialize with dependencies if needed
    }
    
    // MARK: - Start
    /// Builds the ConnectionsView with its ViewModel
    func start() -> some View {
        let viewModel = ConnectionsViewModel()
        return ConnectionsView(viewModel: viewModel)
    }
}
