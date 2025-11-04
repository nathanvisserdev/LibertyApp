//
//  RootCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-11-04.
//

import SwiftUI

@MainActor
final class RootCoordinator {
    private let tabBarCoordinator: TabBarCoordinator

    init(tabBarCoordinator: TabBarCoordinator) {
        self.tabBarCoordinator = tabBarCoordinator
    }

    /// Container for the authenticated app
    func start() -> some View {
        let rootViewModel = RootViewModel(
            model: RootModel()
        )
        return RootView(
            viewModel: rootViewModel,
            tabBarCoordinator: tabBarCoordinator
        )
    }
}

