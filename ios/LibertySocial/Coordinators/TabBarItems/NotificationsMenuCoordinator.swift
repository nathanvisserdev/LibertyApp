//
//  NotificationsMenuCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

/// Stateless coordinator for NotificationsMenu flow - navigation is SwiftUI-owned
final class NotificationsMenuCoordinator {
    
    // MARK: - Init
    init() {
        // Initialize with dependencies if needed
    }
    
    // MARK: - Start
    /// Builds the NotificationsMenuView with its ViewModel
    func start() -> some View {
        let viewModel = NotificationsMenuViewModel()
        return NotificationsMenuView(viewModel: viewModel)
    }
}
