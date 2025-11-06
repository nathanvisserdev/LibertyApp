//
//  SuggestedGroupsViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-27.
//

import Foundation
import Combine

@MainActor
final class SuggestedGroupsViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let model: SuggestedGroupsModel
    
    // MARK: - Published (Output State)
    @Published var joinableGroups: [UserGroup] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Callbacks
    var onDismiss: (() -> Void)?
    var onGroupSelected: ((UserGroup) -> Void)?
    
    // MARK: - Init
    init(model: SuggestedGroupsModel = SuggestedGroupsModel()) {
        self.model = model
    }
    
    // MARK: - Intents (User Actions)
    func fetchJoinableGroups() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Get current user ID
            let userId = try await model.fetchCurrentUserId()
            
            // Fetch joinable groups
            joinableGroups = try await model.fetchJoinableGroups(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching joinable groups: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Actions
    
    func dismiss() {
        onDismiss?()
    }
    
    func selectGroup(_ group: UserGroup) {
        onGroupSelected?(group)
    }
}
