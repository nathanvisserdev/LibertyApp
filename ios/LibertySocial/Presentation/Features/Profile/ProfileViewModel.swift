//
//  ProfileViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    // MARK: - Dependencies
    private let model: ProfileModel
    
    // MARK: - Published
    @Published var profile: UserProfile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isOwnProfile: Bool = false
    
    // MARK: - Init
    init(model: ProfileModel = ProfileModel()) {
        self.model = model
    }
    
    func loadProfile(userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            profile = try await model.fetchUserProfile(userId: userId)
            
            // Check if this is the current user's profile
            isOwnProfile = await checkIfOwnProfile(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func checkIfOwnProfile(userId: String) async -> Bool {
        do {
            let currentUser = try await model.fetchCurrentUser()
            if let currentUserId = currentUser["id"] as? String {
                return currentUserId == userId
            }
        } catch {
            print("❌ Failed to check if own profile: \(error)")
        }
        
        return false
    }
}
