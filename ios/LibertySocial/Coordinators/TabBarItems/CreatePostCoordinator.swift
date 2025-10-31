//
//  CreatePostCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

/// Stateless coordinator for CreatePost flow - navigation is SwiftUI-owned
final class CreatePostCoordinator {
    
    // MARK: - Init
    init() {
        // Initialize with dependencies if needed
    }
    
    // MARK: - Start
    /// Builds the CreatePostView with its ViewModel
    func start() -> some View {
        let viewModel = CreatePostViewModel()
        return CreatePostView(viewModel: viewModel)
    }
}
