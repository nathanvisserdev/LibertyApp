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
    
    // MARK: - Published (State)
    @Published var currentUserPhotoKey: String?
    @Published var currentUserId: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Published (UI State for Navigation)
    @Published var isShowingCompose: Bool = false
    @Published var isShowingSearch: Bool = false
    @Published var isShowingNotifications: Bool = false
    @Published var isShowingProfile: Bool = false
    @Published var isShowingNetworkMenu: Bool = false
    @Published var selectedUserId: String?
    
    // MARK: - Init
    init(model: TabBarModel = TabBarModel()) {
        self.model = model
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
        isShowingSearch = true
    }
    
    func hideSearch() {
        isShowingSearch = false
    }
    
    func tapNotifications() {
        isShowingNotifications = true
    }
    
    func hideNotifications() {
        isShowingNotifications = false
    }
    
    func tapNetworkMenu() {
        isShowingNetworkMenu = true
    }
    
    func hideNetworkMenu() {
        isShowingNetworkMenu = false
    }
    
    func tapProfile(userId: String) {
        selectedUserId = userId
        isShowingProfile = true
    }
    
    func hideProfile() {
        isShowingProfile = false
        selectedUserId = nil
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
