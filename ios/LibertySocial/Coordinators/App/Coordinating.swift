//
//  Coordinating.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-11-04.
//
import Foundation

@MainActor
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
