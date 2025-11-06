//
//  CreateGroupCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI
import Combine

/// Coordinator for CreateGroup flow - manages ViewModel lifecycle and navigation
final class CreateGroupCoordinator {
    
    private let TokenProvider: TokenProviding
    private let AuthManager: AuthManaging
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(TokenProvider: TokenProviding = AuthService.shared, AuthManager: AuthManaging = AuthService.shared) {
        self.TokenProvider = TokenProvider
        self.AuthManager = AuthManager
    }
    
    // MARK: - Start
    /// Builds the CreateGroupView with its ViewModel and sets up navigation observation
    func start(onDismiss: @escaping () -> Void) -> some View {
        let model = CreateGroupModel(TokenProvider: TokenProvider, AuthManager: AuthManager)
        let viewModel = CreateGroupViewModel(model: model)
        
        // Set up callbacks
        viewModel.onFinished = {
            onDismiss()
        }
        viewModel.onCancelled = {
            onDismiss()
        }
        
        return CreateGroupViewWrapper(viewModel: viewModel, coordinator: self)
    }
    
    // MARK: - Observation Setup
    
    /// Called by the wrapper to set up observation of ViewModel navigation signals
    @MainActor
    func observeViewModel(_ viewModel: CreateGroupViewModel, dismiss: @escaping () -> Void) {
        viewModel.didFinishSuccessfully
            .sink { _ in
                // Coordinator executes the dismissal when invites are sent successfully
                dismiss()
            }
            .store(in: &cancellables)
    }
}

// MARK: - View Wrapper

/// Wrapper view that connects the Coordinator to the View's dismiss environment
private struct CreateGroupViewWrapper: View {
    @StateObject private var viewModel: CreateGroupViewModel
    @Environment(\.dismiss) private var dismiss
    
    let coordinator: CreateGroupCoordinator
    
    init(viewModel: CreateGroupViewModel, coordinator: CreateGroupCoordinator) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.coordinator = coordinator
    }
    
    var body: some View {
        CreateGroupView(viewModel: viewModel)
            .onAppear {
                // Set up coordinator observation when view appears
                coordinator.observeViewModel(viewModel) {
                    dismiss()
                }
            }
    }
}
