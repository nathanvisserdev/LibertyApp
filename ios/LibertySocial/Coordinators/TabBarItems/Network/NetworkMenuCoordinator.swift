//
//  NetworkMenuCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

/// Stateless coordinator for NetworkMenu flow - navigation is SwiftUI-owned
final class NetworkMenuCoordinator {
    
    // MARK: - Init
    init() {
        // Initialize with dependencies if needed
    }
    
    // MARK: - Start
    /// Builds the NetworkMenuView with its ViewModel
    func start() -> some View {
        let viewModel = NetworkMenuViewModel()
        return NetworkMenuView(viewModel: viewModel)
    }
}
