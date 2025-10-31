//
//  ProfileMenuCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

/// Stateless coordinator for ProfileMenu flow - navigation is SwiftUI-owned
final class ProfileMenuCoordinator {
    
    // MARK: - Init
    init() {
        // Initialize with dependencies if needed
    }
    
    // MARK: - Start
    /// Builds the ProfileMenuView with its ViewModel
    func start(userId: String?) -> some View {
        let viewModel = ProfileMenuViewModel()
        return ProfileMenuView(viewModel: viewModel, userId: userId)
    }
}
