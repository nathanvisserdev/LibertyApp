//
//  NotificationsMenuCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI
import Combine

/// Coordinator for NotificationsMenu flow
@MainActor
final class NotificationsMenuCoordinator: ObservableObject {
    
    // MARK: - Published State
    @Published var isShowingNotifications: Bool = false
    
    // MARK: - Init
    init() {
        // Initialize with dependencies if needed
    }
    
    // MARK: - Public Methods
    
    /// Presents the NotificationsMenuView
    func showNotifications() {
        isShowingNotifications = true
    }
    
    /// Builds the NotificationsMenuView with its ViewModel
    func makeView() -> some View {
        let viewModel = NotificationsMenuViewModel()
        return NotificationsMenuView(viewModel: viewModel)
    }
}
