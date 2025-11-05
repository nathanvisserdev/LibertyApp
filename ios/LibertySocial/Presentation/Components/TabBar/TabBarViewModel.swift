//
//  TabBarViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-10.
//

import Foundation
import Combine

@MainActor
final class TabBarViewModel: ObservableObject {
    // MARK: - Dependencies
    private let model: TabBarModel
    private let onNotificationsTapped: () -> Void
    private let onNetworkMenuTapped: () -> Void
    private let onSearchTapped: () -> Void
    private let onProfileTapped: (String) -> Void
    
    // MARK: - Published (State)
    @Published var currentUserPhotoKey: String?
    @Published var currentUserId: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Published (UI State for Navigation)
    @Published var isShowingCompose: Bool = false
    
    // MARK: - Init
    init(model: TabBarModel, onNotificationsTapped: @escaping () -> Void, onNetworkMenuTapped: @escaping () -> Void, onSearchTapped: @escaping () -> Void, onProfileTapped: @escaping (String) -> Void) {
        self.model = model
        self.onNotificationsTapped = onNotificationsTapped
        self.onNetworkMenuTapped = onNetworkMenuTapped
        self.onSearchTapped = onSearchTapped
        self.onProfileTapped = onProfileTapped
    }
    
    // MARK: - Intents (Data Actions)
    
    /// Fetch current user's photo and ID from /user/me
    func fetchCurrentUserInfo() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let userInfo = try await model.fetchCurrentUserInfo()
            currentUserPhotoKey = userInfo.photoKey
            currentUserId = userInfo.userId
            isLoading = false
        } catch {
            errorMessage = "Failed to fetch current user info: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Intents (Navigation Actions)
    
    func tapCompose() {
        isShowingCompose = true
    }
    
    func hideCompose() {
        isShowingCompose = false
    }
    
    func tapSearch() {
        onSearchTapped()
    }
    
    func tapNotifications() {
        onNotificationsTapped()
    }
    
    func tapNetworkMenu() {
        onNetworkMenuTapped()
    }
    
    func tapProfile(userId: String) {
        onProfileTapped(userId)
    }
    
    func tapCurrentUserProfile() {
        Task {
            if let userId = currentUserId {
                tapProfile(userId: userId)
            } else {
                // Fetch current user ID if not already loaded
                await fetchCurrentUserInfo()
                if let userId = currentUserId {
                    tapProfile(userId: userId)
                }
            }
        }
    }
}
