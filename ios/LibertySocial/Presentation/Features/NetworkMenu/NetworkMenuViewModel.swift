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
    
    // MARK: - Published (UI State for Navigation)
    @Published var showConnections: Bool = false
    @Published var showGroupsMenu: Bool = false
    @Published var showSubnetMenu: Bool = false
    
    // MARK: - Init
    init(model: NetworkMenuModel = NetworkMenuModel(), AuthManager: AuthManaging = AuthService.shared) {
        self.model = model
        self.AuthManager = AuthManager
    }
    
    // MARK: - Intents (User Actions)
    func showConnectionsView() {
        showConnections = true
    }
    
    func hideConnectionsView() {
        showConnections = false
    }
    
    func showGroupsMenuView() {
        showGroupsMenu = true
    }
    
    func hideGroupsMenuView() {
        showGroupsMenu = false
    }
    
    func showSubnetMenuView() {
        showSubnetMenu = true
    }
    
    func hideSubnetMenuView() {
        showSubnetMenu = false
    }
}
