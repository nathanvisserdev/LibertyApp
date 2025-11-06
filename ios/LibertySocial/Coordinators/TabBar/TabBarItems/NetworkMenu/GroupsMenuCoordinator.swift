//
//  GroupsMenuCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI
import Combine

/// Coordinator for GroupsMenu flow - manages child coordinators for group-related flows
@MainActor
final class GroupsMenuCoordinator: ObservableObject {
    
    // MARK: - Published State
    @Published var isShowingGroupsMenu: Bool = false
    @Published var showCreateGroup: Bool = false
    @Published var showSuggestedGroups: Bool = false
    @Published var selectedGroup: UserGroup? = nil
    
    // MARK: - Dependencies
    private let authenticationManager: AuthManaging
    private let tokenProvider: TokenProviding
    
    // MARK: - Child Coordinators
    private lazy var createGroupCoordinator: CreateGroupCoordinator = {
        CreateGroupCoordinator(
            TokenProvider: tokenProvider,
            AuthManager: authenticationManager
        )
    }()
    
    private lazy var suggestedGroupsCoordinator: SuggestedGroupsCoordinator = {
        SuggestedGroupsCoordinator(
            TokenProvider: tokenProvider,
            AuthManager: authenticationManager
        )
    }()
    
    private lazy var groupCoordinatorFactory: (UserGroup) -> GroupCoordinator = { [unowned self] group in
        GroupCoordinator(
            group: group,
            TokenProvider: self.tokenProvider,
            AuthManager: self.authenticationManager
        )
    }

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
    
    /// Presents the CreateGroup flow
    func presentCreateGroup() {
        showCreateGroup = true
    }
    
    /// Presents the SuggestedGroups flow
    func presentSuggestedGroups() {
        showSuggestedGroups = true
    }
    
    /// Presents the Group detail flow
    func presentGroup(_ group: UserGroup) {
        selectedGroup = group
    }

    /// Builds the GroupsMenuView with its ViewModel
    func makeView() -> some View {
        let viewModel = GroupsMenuViewModel(coordinator: self)
        return GroupsMenuView(viewModel: viewModel, coordinator: self)
    }
    
    // MARK: - Child Coordinator Methods
    
    /// Creates and returns the CreateGroupView via its coordinator
    func makeCreateGroupView() -> some View {
        return createGroupCoordinator.start(onDismiss: { [weak self] in
            self?.showCreateGroup = false
        })
    }
    
    /// Creates and returns the SuggestedGroupsView via its coordinator
    func makeSuggestedGroupsView() -> some View {
        return suggestedGroupsCoordinator.start(
            onDismiss: { [weak self] in
                self?.showSuggestedGroups = false
            },
            onSelect: { [weak self] group in
                self?.showSuggestedGroups = false
                self?.presentGroup(group)
            }
        )
    }
    
    /// Creates and returns the GroupView via its coordinator
    func makeGroupView(for group: UserGroup) -> some View {
        return groupCoordinatorFactory(group).start(onClose: { [weak self] in
            self?.selectedGroup = nil
        })
    }
}
