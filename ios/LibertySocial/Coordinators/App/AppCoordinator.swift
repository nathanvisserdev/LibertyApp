//
//  Coordinator.swift
//  LibertySocial
//
//  Created by AI Assistant on 2025-10-24.
//

import SwiftUI

@MainActor
final class AppCoordinator {
    private let rootCoordinator: RootCoordinator
    
    init() {
        let tabBarCoordinator = TabBarCoordinator()
        self.rootCoordinator = RootCoordinator(
            tabBarCoordinator: tabBarCoordinator
        )
    }
    
    /// Builds the main authenticated view with TabBar at root
    func start() -> some View {
        rootCoordinator.start()
    }
}
