//
//  Coordinator.swift
//  LibertySocial
//
//  Created by AI Assistant on 2025-10-24.
//

import SwiftUI

@MainActor
final class AppCoordinator {
    
    // MARK: - Dependencies
    private let tabBarCoordinator: TabBarCoordinator
    
    // MARK: - Init
    init(tabBarCoordinator: TabBarCoordinator) {
        self.tabBarCoordinator = tabBarCoordinator
    }
    
    convenience init() {
        self.init(tabBarCoordinator: TabBarCoordinator())
    }
    
    // MARK: - Start
    /// Builds the main authenticated view with TabBar at root
    func start() -> some View {
        tabBarCoordinator.start()
    }
}
