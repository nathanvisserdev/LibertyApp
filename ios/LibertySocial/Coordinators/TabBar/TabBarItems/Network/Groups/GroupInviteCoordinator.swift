//
//  GroupInviteCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI
import Combine

/// Coordinator for GroupInvite flow - manages ViewModel lifecycle and navigation
final class GroupInviteCoordinator {
    
    private let groupId: String
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(groupId: String) {
        self.groupId = groupId
    }
    
    // MARK: - Start
    /// Builds the GroupInviteView with its ViewModel and sets up navigation observation
    func start() -> some View {
        let model = GroupInviteModel()
        let viewModel = GroupInviteViewModel(model: model, groupId: groupId)
        
        return GroupInviteViewWrapper(viewModel: viewModel, coordinator: self)
    }
    
    // MARK: - Observation Setup
    
    /// Called by the wrapper to set up observation of ViewModel navigation signals
    @MainActor
    func observeViewModel(_ viewModel: GroupInviteViewModel, dismiss: @escaping () -> Void) {
        viewModel.didFinishSuccessfully
            .sink { _ in
                // Coordinator executes the dismissal
                dismiss()
            }
            .store(in: &cancellables)
    }
}

// MARK: - View Wrapper

/// Wrapper view that connects the Coordinator to the View's dismiss environment
private struct GroupInviteViewWrapper: View {
    @StateObject private var viewModel: GroupInviteViewModel
    @Environment(\.dismiss) private var dismiss
    
    let coordinator: GroupInviteCoordinator
    
    init(viewModel: GroupInviteViewModel, coordinator: GroupInviteCoordinator) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.coordinator = coordinator
    }
    
    var body: some View {
        GroupInviteView(viewModel: viewModel)
            .onAppear {
                // Set up coordinator observation when view appears
                coordinator.observeViewModel(viewModel) {
                    dismiss()
                }
            }
    }
}
