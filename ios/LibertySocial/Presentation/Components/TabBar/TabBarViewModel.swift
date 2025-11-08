
import Foundation
import Combine
import SwiftUI

@MainActor
final class TabBarViewModel: ObservableObject {
    private let model: TabBarModel
    private let onTabSelected: ((TabBarItem) -> Void)?
    private let onNotificationsTapped: () -> Void
    private let onNetworkMenuTapped: () -> Void
    private let onComposeTapped: () -> Void
    private let onSearchTapped: () -> Void
    private let onProfileTapped: (String) -> Void
    
    var onShowNotificationsMenu: (() -> AnyView)?
    var onShowNetworkMenu: (() -> AnyView)?
    var onShowSearch: (() -> AnyView)?
    var onShowProfile: (() -> AnyView)?
    var onShowCreatePost: (() -> AnyView)?
    
    @Published var currentUserPhotoKey: String?
    @Published var currentUserId: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isShowingNotifications: Bool = false
    @Published var isShowingNetworkMenu: Bool = false
    @Published var isShowingSearch: Bool = false
    @Published var isShowingProfile: Bool = false
    @Published var isShowingCreatePost: Bool = false
    
    init(model: TabBarModel,
         onTabSelected: ((TabBarItem) -> Void)? = nil,
         onNotificationsTapped: @escaping () -> Void,
         onNetworkMenuTapped: @escaping () -> Void,
         onComposeTapped: @escaping () -> Void,
         onSearchTapped: @escaping () -> Void,
         onProfileTapped: @escaping (String) -> Void) {
        self.model = model
        self.onTabSelected = onTabSelected
        self.onNotificationsTapped = onNotificationsTapped
        self.onNetworkMenuTapped = onNetworkMenuTapped
        self.onComposeTapped = onComposeTapped
        self.onSearchTapped = onSearchTapped
        self.onProfileTapped = onProfileTapped
    }
    
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
    
    func tapCompose() {
        isShowingCreatePost = true
        onComposeTapped()
    }
    
    func tapSearch() {
        onTabSelected?(.search)
        isShowingSearch = true
        onSearchTapped()
    }
    
    func tapNotifications() {
        onTabSelected?(.notifications)
        isShowingNotifications = true
        onNotificationsTapped()
    }
    
    func tapNetworkMenu() {
        onTabSelected?(.networkMenu)
        isShowingNetworkMenu = true
        onNetworkMenuTapped()
    }
    
    func tapProfile(userId: String) {
        onTabSelected?(.profile)
        isShowingProfile = true
        onProfileTapped(userId)
   }
    
    func tapCurrentUserProfile() {
        Task {
            if let userId = currentUserId {
                tapProfile(userId: userId)
            } else {
                await fetchCurrentUserInfo()
                if let userId = currentUserId {
                    tapProfile(userId: userId)
                }
            }
        }
    }
}
