
import Foundation
import Combine
import SwiftUI

@MainActor
final class TabBarViewModel: ObservableObject {
    private let model: TabBarModel
    private let onTabSelected: ((TabBarItem) -> Void)?
    private let notificationsMenuTapped: () -> Void
    private let networkMenuTapped: () -> Void
    private let createPostTapped: () -> Void
    private let searchTapped: () -> Void
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
         notificationsMenuTapped: @escaping () -> Void,
         networkMenuTapped: @escaping () -> Void,
         createPostTapped: @escaping () -> Void,
         searchTapped: @escaping () -> Void,
         onProfileTapped: @escaping (String) -> Void) {
        self.model = model
        self.onTabSelected = onTabSelected
        self.notificationsMenuTapped = notificationsMenuTapped
        self.networkMenuTapped = networkMenuTapped
        self.createPostTapped = createPostTapped
        self.searchTapped = searchTapped
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
    
    func onNotificationsMenuTap() {
        onTabSelected?(.notifications)
        isShowingNotifications = true
        notificationsMenuTapped()
    }
    
    func onNetworkMenuTap() {
        onTabSelected?(.networkMenu)
        isShowingNetworkMenu = true
        networkMenuTapped()
    }
    
    func onCreatePostTap() {
        isShowingCreatePost = true
        createPostTapped()
    }
    
    func onSearchTap() {
        onTabSelected?(.search)
        isShowingSearch = true
        searchTapped()
    }
    
    func mainMenuTapped(userId: String) {
        onTabSelected?(.profile)
        isShowingProfile = true
        onProfileTapped(userId)
   }
    
    func onMainMenuTap() {
        Task {
            if let userId = currentUserId {
                mainMenuTapped(userId: userId)
            } else {
                await fetchCurrentUserInfo()
                if let userId = currentUserId {
                    mainMenuTapped(userId: userId)
                }
            }
        }
    }
}
