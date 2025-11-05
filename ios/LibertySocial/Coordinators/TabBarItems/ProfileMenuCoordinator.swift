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
    
    // MARK: - Private State
    private var currentUserId: String?
    
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
    
    /// Builds the ProfileMenuView with its ViewModel
    func makeView() -> some View {
        let viewModel = ProfileMenuViewModel()
        return ProfileMenuView(
            viewModel: viewModel,
            userId: currentUserId,
            makeProfileCoordinator: { id in
                ProfileCoordinator(
                    userId: id,
                    authenticationManager: self.authenticationManager,
                    tokenProvider: self.tokenProvider
                )
            }
        )
    }
}
