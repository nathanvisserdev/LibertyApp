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
    @Published var isShowingProfile: Bool = false
    
    // MARK: - Private State
    private var selectedUserId: String?
    
    // MARK: - Child Coordinators
    private var profileCoordinator: ProfileCoordinator?
    
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
    
    /// Presents a profile for the specified user
    func showProfile(for userId: String) {
        selectedUserId = userId
        profileCoordinator = ProfileCoordinator(
            userId: userId,
            authenticationManager: authenticationManager,
            tokenProvider: tokenProvider
        )
        isShowingProfile = true
    }

    /// Builds the ConnectionsView with its ViewModel
    func makeView() -> some View {
        let viewModel = ConnectionsViewModel(
            onUserSelected: { [weak self] userId in
                self?.showProfile(for: userId)
            }
        )
        return ConnectionsView(
            viewModel: viewModel,
            coordinator: self
        )
    }
    
    /// Builds the ProfileView for the selected user
    func makeProfileView() -> some View {
        guard let coordinator = profileCoordinator else {
            return AnyView(EmptyView())
        }
        return AnyView(coordinator.start())
    }
}
