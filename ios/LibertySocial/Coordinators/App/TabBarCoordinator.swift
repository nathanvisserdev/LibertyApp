//
//  TabBarCoordinator.swift
//  LibertySocial
//
//  Created by AI Assistant on 2025-10-24.
//

import SwiftUI

/// Coordinator for TabBar - owns the main feed view and tab bar UI
@MainActor
final class TabBarCoordinator {
    
    // MARK: - Dependencies
    private let feedCoordinator: FeedCoordinator
    
    // MARK: - Init
    init(feedCoordinator: FeedCoordinator) {
        self.feedCoordinator = feedCoordinator
    }
    
    convenience init() {
        self.init(feedCoordinator: FeedCoordinator())
    }
    
    // MARK: - Start
    /// Builds the TabBarView with FeedView and tab bar at bottom
    func start() -> some View {
        feedCoordinator.start()
            .safeAreaInset(edge: .bottom) {
                let viewModel = TabBarViewModel()
                TabBarView(viewModel: viewModel)
                    .ignoresSafeArea(edges: .bottom)
            }
    }
}
