//
//  GroupsMenuCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI
import Combine

/// Coordinator for GroupsMenu flow
@MainActor
final class GroupsMenuCoordinator: ObservableObject {
    
    // MARK: - Published State
    @Published var isShowingGroupsMenu: Bool = false
    
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
    
    /// Presents the GroupsMenuView
    func showGroupsMenu() {
        isShowingGroupsMenu = true
    }

    /// Builds the GroupsMenuView with its ViewModel
    func makeView() -> some View {
        let viewModel = GroupsMenuViewModel()
        return GroupsMenuView(viewModel: viewModel)
    }
}
