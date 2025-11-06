//
//  CreatePostCoordinator.swift
//  LibertySocial
//
//  Created by AI Assistant on 2025-11-06.
//

import SwiftUI
import Combine

/// Coordinator for CreatePost flow
@MainActor
final class CreatePostCoordinator: ObservableObject {
    
    // MARK: - Public Methods
    
    /// Starts the CreatePost flow
    func start() -> some View {
        let viewModel = CreatePostViewModel()
        return CreatePostView(viewModel: viewModel)
    }
}
