//
//  TabBarCoordinator.swift
//  LibertySocial
//
//  Created by AI Assistant on 2025-10-24.
//

import SwiftUI
import Combine

@MainActor
final class TabBarCoordinator: ObservableObject {
    // MARK: - Published Properties (Navigation State)
    @Published var isShowingCompose: Bool = false
    @Published var isShowingSearch: Bool = false
    @Published var isShowingNotifications: Bool = false
    @Published var isShowingProfile: Bool = false
    @Published var selectedUserId: String?
    
    // MARK: - Dependencies
    private let viewModel: TabBarViewModel
    
    init(viewModel: TabBarViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Navigation Actions
    func showCompose() {
        isShowingCompose = true
    }
    
    func hideCompose() {
        isShowingCompose = false
    }
    
    func showSearch() {
        isShowingSearch = true
    }
    
    func hideSearch() {
        isShowingSearch = false
    }
    
    func showNotifications() {
        isShowingNotifications = true
    }
    
    func hideNotifications() {
        isShowingNotifications = false
    }
    
    func showProfile(userId: String) {
        selectedUserId = userId
        isShowingProfile = true
    }
    
    func hideProfile() {
        isShowingProfile = false
        selectedUserId = nil
    }
    
    func showCurrentUserProfile() {
        Task {
            if let userId = viewModel.currentUserId {
                showProfile(userId: userId)
            } else {
                // Fetch current user ID if not already loaded
                await viewModel.fetchCurrentUserInfo()
                if let userId = viewModel.currentUserId {
                    showProfile(userId: userId)
                }
            }
        }
    }
}
