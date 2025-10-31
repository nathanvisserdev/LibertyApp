//
//  GroupsMenuViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import Foundation
import Combine

@MainActor
final class GroupsMenuViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let model: GroupsMenuModel
    private let authService: AuthServiceProtocol
    
    // MARK: - Published (Output State)
    @Published var userGroups: [UserGroup] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Published (UI State for Navigation)
    @Published var showCreateGroup: Bool = false
    @Published var showSuggestedGroups: Bool = false
    @Published var selectedGroup: UserGroup?
    
    // MARK: - Init
    init(model: GroupsMenuModel = GroupsMenuModel(), authService: AuthServiceProtocol = AuthService.shared) {
        self.model = model
        self.authService = authService
    }
    
    // MARK: - Intents (User Actions)
    func fetchUserGroups() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Get current user ID
            let currentUser = try await authService.fetchCurrentUserTyped()
            
            // Fetch user's groups
            userGroups = try await model.fetchUserGroups(userId: currentUser.id)
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching user groups: \(error)")
        }
        
        isLoading = false
    }
    
    func showCreateGroupView() {
        showCreateGroup = true
    }
    
    func hideCreateGroupView() {
        showCreateGroup = false
    }
    
    func showSuggestedGroupsView() {
        showSuggestedGroups = true
    }
    
    func hideSuggestedGroupsView() {
        showSuggestedGroups = false
    }
    
    func showGroup(_ group: UserGroup) {
        selectedGroup = group
    }
    
    func hideGroup() {
        selectedGroup = nil
    }
}
