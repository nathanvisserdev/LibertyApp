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
    @Published var profile: UserProfile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func loadProfile(userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            profile = try await AuthService.fetchUserProfile(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
