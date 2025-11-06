//
//  ProfileMenuCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI
import Combine

/// Coordinator for ProfileMenu flow
@MainActor
final class ProfileMenuCoordinator: ObservableObject {
    
    // MARK: - Published State
    @Published var isShowingProfile: Bool = false
    @Published var isShowingChildProfile: Bool = false
    
    // MARK: - Private State
    private var currentUserId: String?
    private var selectedUserId: String?
    
    // MARK: - Child Coordinators
    private var profileCoordinator: ProfileCoordinator?
    
    // MARK: - Dependencies
    private let authenticationManager: AuthManaging
    private let tokenProvider: TokenProviding

    // MARK: - Init
    init(authenticationManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.authenticationManager = authenticationManager
        self.tokenProvider = tokenProvider
    }
    
    // MARK: - Public Methods
    
    /// Presents the ProfileMenuView for the specified user
    func showProfile(userId: String) {
        currentUserId = userId
        isShowingProfile = true
    }
    
    /// Presents a child profile from within ProfileMenuView
    func showProfile(for userId: String) {
        selectedUserId = userId
        profileCoordinator = ProfileCoordinator(
            userId: userId,
            authenticationManager: authenticationManager,
            tokenProvider: tokenProvider
        )
        isShowingChildProfile = true
    }
    
    /// Opens the followers list for a specific user (deeplink/notification entry)
    /// Creates or retrieves the ProfileCoordinator and delegates to it
    func openFollowers(for userId: String) {
        // First, ensure we have a profile coordinator for this user
        if profileCoordinator == nil || selectedUserId != userId {
            selectedUserId = userId
            profileCoordinator = ProfileCoordinator(
                userId: userId,
                authenticationManager: authenticationManager,
                tokenProvider: tokenProvider
            )
        }
        
        // Show the profile if not already showing
        if !isShowingChildProfile {
            isShowingChildProfile = true
        }
        
        // Delegate to the profile coordinator to open followers
        profileCoordinator?.openFollowers(of: userId)
    }
    
    /// Opens the following list for a specific user (deeplink/notification entry)
    /// Creates or retrieves the ProfileCoordinator and delegates to it
    func openFollowing(for userId: String) {
        // First, ensure we have a profile coordinator for this user
        if profileCoordinator == nil || selectedUserId != userId {
            selectedUserId = userId
            profileCoordinator = ProfileCoordinator(
                userId: userId,
                authenticationManager: authenticationManager,
                tokenProvider: tokenProvider
            )
        }
        
        // Show the profile if not already showing
        if !isShowingChildProfile {
            isShowingChildProfile = true
        }
        
        // Delegate to the profile coordinator to open following
        profileCoordinator?.openFollowing(of: userId)
    }
    
    /// Builds the ProfileMenuView with its ViewModel
    func makeView() -> some View {
        guard let userId = currentUserId else {
            return AnyView(EmptyView())
        }
        
        let viewModel = ProfileMenuViewModel(
            userId: userId,
            onProfileTapped: { [weak self] id in
                self?.showProfile(for: id)
            }
        )
        return AnyView(ProfileMenuView(
            viewModel: viewModel,
            coordinator: self
        ))
    }
    
    /// Builds the child ProfileView for the selected user
    func makeProfileView() -> some View {
        guard let coordinator = profileCoordinator else {
            return AnyView(EmptyView())
        }
        return AnyView(coordinator.start())
    }
}
