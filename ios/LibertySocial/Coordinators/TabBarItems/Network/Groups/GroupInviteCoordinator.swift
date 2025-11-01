//
//  GroupInviteCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

/// Stateless coordinator for GroupInvite flow - navigation is SwiftUI-owned
final class GroupInviteCoordinator {
    
    private let groupId: String
    
    // MARK: - Init
    init(groupId: String) {
        self.groupId = groupId
    }
    
    // MARK: - Start
    /// Builds the GroupInviteView with its ViewModel
    func start() -> some View {
        let model = GroupInviteModel()
        let viewModel = GroupInviteViewModel(model: model, groupId: groupId)
        return GroupInviteView(viewModel: viewModel)
    }
}
