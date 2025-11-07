//
//  CreateGroupCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

/// Coordinator for CreateGroup flow - manages ViewModel lifecycle and navigation for both CreateGroupView and SelectRoundTableAdminsView
@MainActor
final class CreateGroupCoordinator {
    
    private let tokenProvider: TokenProviding
    private let authManager: AuthManaging
    
    // MARK: - Child Coordinators
    private var groupInviteCoordinator: GroupInviteCoordinator?
    
    // MARK: - Shared ViewModel
    private var viewModel: CreateGroupViewModel?
    
    // MARK: - Init
    init(tokenProvider: TokenProviding = AuthService.shared, authManager: AuthManaging = AuthService.shared) {
        self.tokenProvider = tokenProvider
        self.authManager = authManager
    }
    
    // MARK: - Start
    /// Builds the CreateGroupView with its ViewModel
    func start(onDismiss: @escaping () -> Void) -> some View {
        let model = CreateGroupModel(TokenProvider: tokenProvider, AuthManager: authManager)
        let viewModel = CreateGroupViewModel(model: model, coordinator: self)
        self.viewModel = viewModel
        
        // Set up callbacks
        viewModel.onFinished = onDismiss
        viewModel.onCancelled = onDismiss
        viewModel.onRequestAdminSelection = { [weak self] in
            self?.presentAdminSelection()
        }
        
        return CreateGroupViewWrapper(viewModel: viewModel, coordinator: self)
    }
    
    // MARK: - Navigation Methods
    
    /// Presents the admin selection view
    func presentAdminSelection() {
        viewModel?.showAdminSelection = true
    }
    
    /// Dismisses the admin selection view
    func dismissAdminSelection() {
        viewModel?.showAdminSelection = false
    }
    
    // MARK: - Child Coordinator Methods
    
    /// Creates and returns the SelectRoundTableAdminsView with the shared ViewModel
    func makeAdminSelectionView() -> some View {
        guard let viewModel = viewModel else {
            return AnyView(EmptyView())
        }
        return AnyView(SelectRoundTableAdminsView(viewModel: viewModel))
    }
    
    /// Creates and returns the GroupInviteView via its coordinator
    func makeGroupInviteView(for groupId: String) -> some View {
        let coordinator = GroupInviteCoordinator(groupId: groupId)
        self.groupInviteCoordinator = coordinator
        return coordinator.start()
    }
}

// MARK: - View Wrapper

/// Wrapper view that holds the coordinator and manages the admin selection sheet
private struct CreateGroupViewWrapper: View {
    @ObservedObject var viewModel: CreateGroupViewModel
    let coordinator: CreateGroupCoordinator
    
    var body: some View {
        CreateGroupView(viewModel: viewModel, coordinator: coordinator)
            .sheet(isPresented: $viewModel.showAdminSelection) {
                coordinator.makeAdminSelectionView()
            }
    }
}
