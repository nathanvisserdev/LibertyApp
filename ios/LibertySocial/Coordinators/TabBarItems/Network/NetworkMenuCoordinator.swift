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

    init(authenticationManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.authenticationManager = authenticationManager
        self.tokenProvider = tokenProvider
    }
    
    // MARK: - Public Methods
    
    /// Presents the NetworkMenuView
    func showNetworkMenu() {
        isShowingNetworkMenu = true
    }
    
    /// Builds the NetworkMenuView with its ViewModel
    func makeView() -> some View {
        let viewModel = NetworkMenuViewModel()
        return NetworkMenuView(
            viewModel: viewModel,
            makeConnectionsCoordinator: {
                ConnectionsCoordinator(
                    authenticationManager: self.authenticationManager,
                    tokenProvider: self.tokenProvider
                )
            },
            makeGroupsMenuCoordinator: {
                GroupsMenuCoordinator(
                    authenticationManager: self.authenticationManager,
                    tokenProvider: self.tokenProvider
                )
            },
            makeSubnetMenuCoordinator: {
                SubnetMenuCoordinator(
                    authenticationManager: self.authenticationManager,
                    tokenProvider: self.tokenProvider
                )
            }
        )
    }
}
