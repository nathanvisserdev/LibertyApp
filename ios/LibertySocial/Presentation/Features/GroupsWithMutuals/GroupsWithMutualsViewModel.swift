//
//  GroupWithMutualsViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-27.
//

import Foundation
import Combine

@MainActor
final class GroupsWithMutualsViewModel: ObservableObject {
    @Published var joinableGroups: [UserGroup] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    func fetchJoinableGroups() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Get current user ID
            let currentUser = try await authService.fetchCurrentUserTyped()
            
            // Fetch joinable groups
            let groups = try await GroupsWithMutualsModel.fetchJoinableGroups(userId: currentUser.id)
            joinableGroups = groups
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching joinable groups: \(error)")
        }
        
        isLoading = false
    }
}
