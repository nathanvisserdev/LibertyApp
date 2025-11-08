//
//  ProfileMenuCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI
import Combine

@MainActor
final class ProfileMenuCoordinator: ObservableObject {
    @Published var isShowingProfile: Bool = false
    
    private var currentUserId: String?
    private var selectedUserId: String?
    private var profileCoordinator: ProfileCoordinator?
    private let authenticationManager: AuthManaging
    private let tokenProvider: TokenProviding
    
    // Callbacks for parent coordinator to wire
    var onLogout: (() -> Void)?
    var onUserSelected: ((String) -> Void)?

    init(authenticationManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.authenticationManager = authenticationManager
        self.tokenProvider = tokenProvider
    }
    
    func showProfile(userId: String) {
        currentUserId = userId
        isShowingProfile = true
    }
    
    func showProfile(for userId: String) {
        selectedUserId = userId
        profileCoordinator = ProfileCoordinator(
            userId: userId,
            authenticationManager: authenticationManager,
            tokenProvider: tokenProvider
        )
    }
    
    func openFollowers(for userId: String) {
        if profileCoordinator == nil || selectedUserId != userId {
            selectedUserId = userId
            profileCoordinator = ProfileCoordinator(
                userId: userId,
                authenticationManager: authenticationManager,
                tokenProvider: tokenProvider
            )
        }
        
        profileCoordinator?.openFollowers(of: userId)
    }
    
    func openFollowing(for userId: String) {
        if profileCoordinator == nil || selectedUserId != userId {
            selectedUserId = userId
            profileCoordinator = ProfileCoordinator(
                userId: userId,
                authenticationManager: authenticationManager,
                tokenProvider: tokenProvider
            )
        }
        
        profileCoordinator?.openFollowing(of: userId)
    }
    
    func makeView() -> some View {
        guard let userId = currentUserId else {
            return AnyView(EmptyView())
        }
        
        let model = ProfileMenuModel()
        let viewModel = ProfileMenuViewModel(
            model: model,
            userId: userId,
            onProfileTapped: { [weak self] id in
                self?.showProfile(for: id)
            }
        )
        
        viewModel.onShowProfile = { [weak self] in
            guard let self = self, let coordinator = self.profileCoordinator else {
                return AnyView(EmptyView())
            }
            return AnyView(coordinator.start())
        }
        
        return AnyView(ProfileMenuView(viewModel: viewModel))
    }
}
