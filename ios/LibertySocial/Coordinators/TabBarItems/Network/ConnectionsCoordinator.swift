//
//  ConnectionsCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

@MainActor
final class ConnectionsCoordinator {
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
    /// Builds the ConnectionsView with its ViewModel
    func start() -> some View {
        let viewModel = ConnectionsViewModel()
        return ConnectionsView(
            viewModel: viewModel,
            makeProfileCoordinator: { userId in
                ProfileCoordinator(
                    userId: userId,
                    authenticationManager: self.authenticationManager,
                    tokenProvider: self.tokenProvider
                )
            }
        )
    }
}
