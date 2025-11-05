//
//  NetworkMenuCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

@MainActor
final class NetworkMenuCoordinator {
    // MARK: - Dependencies
    private let authenticationManager: AuthManaging
    private let tokenProvider: TokenProviding

    // MARK: - Init
    init(authenticationManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.authenticationManager = authenticationManager
        self.tokenProvider = tokenProvider
    }
    
    // MARK: - Start
    /// Builds the NetworkMenuView with its ViewModel
    func start() -> some View {
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
