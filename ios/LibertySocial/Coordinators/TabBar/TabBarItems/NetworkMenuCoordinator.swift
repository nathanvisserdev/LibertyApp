//
//  NetworkMenuCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI
import Combine

@MainActor
final class NetworkMenuCoordinator: ObservableObject {
    @Published var isShowingNetworkMenu: Bool = false
    
    private let authenticationManager: AuthManaging
    private let tokenProvider: TokenProviding
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
    
    func showNetworkMenu() {
        isShowingNetworkMenu = true
    }
    
    private func showConnections() {
        connectionsListCoordinator.showConnections()
    }
    
    private func showGroupsMenu() {
        groupsMenuCoordinator.showGroupsMenu()
    }
    
    private func showSubnetMenu() {
        subnetMenuCoordinator.showSubnetMenu()
    }
    
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
        
        viewModel.onShowConnections = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.connectionsListCoordinator.makeView())
        }
        
        viewModel.onShowGroupsMenu = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.groupsMenuCoordinator.makeView())
        }
        
        viewModel.onShowSubnetMenu = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.subnetMenuCoordinator.makeView())
        }
        
        return NetworkMenuView(viewModel: viewModel)
    }
}
