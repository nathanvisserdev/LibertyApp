//
//  NetworkViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-26.
//

import Foundation
import Combine

@MainActor
final class NetworkViewModel: ObservableObject {
    @Published var userGroups: [UserGroup] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    func fetchUserGroups() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Get current user ID
            let currentUser = try await authService.fetchCurrentUserTyped()
            
            // Fetch user's groups
            let groups = try await NetworkModel.fetchUserGroups(userId: currentUser.id)
            userGroups = groups
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching user groups: \(error)")
        }
        
        isLoading = false
    }
}
