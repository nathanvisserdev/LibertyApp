//
//  GroupsMenuViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class GroupsMenuViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let model: GroupsMenuModel
    private let AuthManager: AuthManaging
    private let groupService: GroupSession
    private weak var coordinator: GroupsMenuCoordinator?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published (Output State)
    @Published var userGroups: [UserGroup] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Init
    init(coordinator: GroupsMenuCoordinator? = nil, model: GroupsMenuModel = GroupsMenuModel(), AuthManager: AuthManaging = AuthService.shared, groupService: GroupSession = GroupService.shared) {
        self.coordinator = coordinator
        self.model = model
        self.AuthManager = AuthManager
        self.groupService = groupService
        
        // Subscribe to group changes
        groupService.groupsDidChange
            .sink { [weak self] in
                Task { @MainActor [weak self] in
                    await self?.fetchUserGroups()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Intents (User Actions)
    func fetchUserGroups() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Get current user ID
            let currentUser = try await AuthManager.fetchCurrentUserTyped()
            
            // Fetch user's groups via service (with caching)
            userGroups = try await groupService.getUserGroups(userId: currentUser.id)
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching user groups: \(error)")
        }
        
        isLoading = false
    }
    
    func showCreateGroupView() {
        coordinator?.presentCreateGroup()
    }
    
    func showSuggestedGroupsView() {
        coordinator?.presentSuggestedGroups()
    }
    
    func showGroup(_ group: UserGroup) {
        coordinator?.presentGroup(group)
    }
}
