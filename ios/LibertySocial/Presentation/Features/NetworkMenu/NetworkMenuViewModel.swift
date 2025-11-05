//
//  NetworkMenuViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-26.
//

import Foundation
import Combine

@MainActor
final class NetworkMenuViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let model: NetworkMenuModel
    private let AuthManager: AuthManaging
    private let onConnectionsTapped: () -> Void
    private let onGroupsMenuTapped: () -> Void
    private let onSubnetMenuTapped: () -> Void
    
    // MARK: - Init
    init(
        model: NetworkMenuModel = NetworkMenuModel(),
        AuthManager: AuthManaging = AuthService.shared,
        onConnectionsTapped: @escaping () -> Void,
        onGroupsMenuTapped: @escaping () -> Void,
        onSubnetMenuTapped: @escaping () -> Void
    ) {
        self.model = model
        self.AuthManager = AuthManager
        self.onConnectionsTapped = onConnectionsTapped
        self.onGroupsMenuTapped = onGroupsMenuTapped
        self.onSubnetMenuTapped = onSubnetMenuTapped
    }
    
    // MARK: - Intents (User Actions)
    func showConnectionsView() {
        onConnectionsTapped()
    }
    
    func showGroupsMenuView() {
        onGroupsMenuTapped()
    }
    
    func showSubnetMenuView() {
        onSubnetMenuTapped()
    }
}
