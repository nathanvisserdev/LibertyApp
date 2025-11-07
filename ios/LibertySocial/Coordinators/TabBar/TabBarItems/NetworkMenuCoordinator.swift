//
//  NetworkMenuCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI
import Combine

/// Coordinator for NetworkMenu flow
@MainActor
final class NetworkMenuCoordinator: ObservableObject {
    
    // MARK: - Published State
    @Published var isShowingNetworkMenu: Bool = false
    
    // MARK: - Dependencies
    private let authenticationManager: AuthManaging
    private let tokenProvider: TokenProviding
    
    // MARK: - Child Coordinators
    private let connectionsListCoordinator: ConnectionsListCoordinator
    private let groupsMenuCoordinator: GroupsMenuCoordinator
    private let subnetMenuCoordinator: SubnetMenuCoordinator

    init(authenticationManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.authenticationManager = authenticationManager
        self.tokenProvider = tokenProvider
        self.connectionsListCoordinator = ConnectionsListCoordinator(
            authenticationManager: authenticationManager,
            tokenProvider: tokenProvider
        )
        self.groupsMenuCoordinator = GroupsMenuCoordinator(
            authenticationManager: authenticationManager,
            tokenProvider: tokenProvider
        )
        self.subnetMenuCoordinator = SubnetMenuCoordinator(
            authenticationManager: authenticationManager,
            tokenProvider: tokenProvider
        )
    }
    
    // MARK: - Public Methods
    
    /// Presents the NetworkMenuView
    func showNetworkMenu() {
        isShowingNetworkMenu = true
    }
    
    /// Presents the ConnectionsListView
    private func showConnections() {
        connectionsListCoordinator.showConnections()
    }
    
    /// Presents the GroupsMenuView
    private func showGroupsMenu() {
        groupsMenuCoordinator.showGroupsMenu()
    }
    
    /// Presents the SubnetMenuView
    private func showSubnetMenu() {
        subnetMenuCoordinator.showSubnetMenu()
    }
    
    /// Builds the NetworkMenuView with its ViewModel
    func makeView() -> some View {
        let viewModel = NetworkMenuViewModel(
            onConnectionsTapped: { [weak self] in
                self?.showConnections()
            },
            onGroupsMenuTapped: { [weak self] in
                self?.showGroupsMenu()
            },
            onSubnetMenuTapped: { [weak self] in
                self?.showSubnetMenu()
            }
        )
        return NetworkMenuView(
            viewModel: viewModel,
            connectionsListCoordinator: connectionsListCoordinator,
            groupsMenuCoordinator: groupsMenuCoordinator,
            subnetMenuCoordinator: subnetMenuCoordinator
        )
    }
}
