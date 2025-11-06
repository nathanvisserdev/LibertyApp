//
//  FollowersListViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import Foundation
import Combine

@MainActor
final class FollowersListViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let model: FollowersListModel
    private let userId: String
    private let onUserSelected: (String) -> Void
    
    // MARK: - Published State
    @Published var followers: [FollowerUser] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Init
    init(model: FollowersListModel = FollowersListModel(),
         userId: String,
         onUserSelected: @escaping (String) -> Void) {
        self.model = model
        self.userId = userId
        self.onUserSelected = onUserSelected
    }
    
    // MARK: - Intents
    func selectUser(_ userId: String) {
        onUserSelected(userId)
    }
    
    func fetchFollowers() async {
        isLoading = true
        errorMessage = nil
        
        do {
            followers = try await model.fetchFollowers(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching followers: \(error)")
        }
        
        isLoading = false
    }
}
