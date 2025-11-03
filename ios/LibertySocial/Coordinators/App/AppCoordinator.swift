//
//  Coordinator.swift
//  LibertySocial
//
//  Created by AI Assistant on 2025-10-24.
//

import SwiftUI

/// Base protocol for all coordinators
protocol Coordinator: AnyObject {
    func start()
}

/// Coordinator that can present child coordinators
protocol ParentCoordinator: Coordinator {
    var childCoordinators: [Coordinator] { get set }
    func addChild(_ coordinator: Coordinator)
    func removeChild(_ coordinator: Coordinator)
}

extension ParentCoordinator {
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}

// MARK: - App Coordinator

/// Stateless coordinator for the main authenticated user flow
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
