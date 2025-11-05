//
//  ConnectionsCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI
import Combine

/// Coordinator for Connections flow
@MainActor
final class ConnectionsCoordinator: ObservableObject {
    
    // MARK: - Published State
    @Published var isShowingConnections: Bool = false
    
    // MARK: - Dependencies
    private let authenticationManager: AuthManaging
    private let tokenProvider: TokenProviding

    // MARK: - Init
    init(authenticationManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.authenticationManager = authenticationManager
        self.tokenProvider = tokenProvider
    }
    
    // MARK: - Public Methods
    
    /// Presents the ConnectionsView
    func showConnections() {
        isShowingConnections = true
    }

    /// Builds the ConnectionsView with its ViewModel
    func makeView() -> some View {
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
