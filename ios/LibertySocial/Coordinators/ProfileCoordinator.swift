//
//  ProfileCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI
import Combine

@MainActor
final class ProfileCoordinator: ObservableObject {
    
    // MARK: - Published State
    @Published var isShowingFollowers: Bool = false
    @Published var isShowingFollowing: Bool = false
    @Published var isShowingConnect: Bool = false
    
    // MARK: - Child Coordinators
    private var followersCoordinator: FollowersListCoordinator?
    private var followingCoordinator: FollowingListCoordinator?
    private var connectCoordinator: ConnectCoordinator?
    
    // MARK: - Dependencies
    private let userId: String
    private let authenticationManager: AuthManaging
    private let tokenProvider: TokenProviding

    init(userId: String,
         authenticationManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.userId = userId
        self.authenticationManager = authenticationManager
        self.tokenProvider = tokenProvider
    }
    
    // MARK: - Public Methods
    
    /// Presents the followers list for the specified user
    func showFollowers(for userId: String) {
        followersCoordinator = FollowersListCoordinator(
            userId: userId,
            authenticationManager: authenticationManager,
            tokenProvider: tokenProvider
        )
        isShowingFollowers = true
    }
    
    /// Presents the following list for the specified user
    func showFollowing(for userId: String) {
        followingCoordinator = FollowingListCoordinator(
            userId: userId,
            authenticationManager: authenticationManager,
            tokenProvider: tokenProvider
        )
        isShowingFollowing = true
    }
    
    /// Presents the connect view for the specified user
    func showConnect(userId: String, firstName: String, isPrivate: Bool) {
        connectCoordinator = ConnectCoordinator(
            firstName: firstName,
            userId: userId,
            isPrivate: isPrivate,
            TokenProvider: tokenProvider,
            AuthManager: authenticationManager
        )
        isShowingConnect = true
    }

    func start() -> some View {
        let model = ProfileModel()
        let viewModel = ProfileViewModel(
            model: model,
            makeMediaVM: { key in
                let mediaModel = MediaModel(TokenProvider: self.tokenProvider)
                return MediaViewModel(mediaKey: key, model: mediaModel)
            },
            authenticationManager: authenticationManager,
            onShowFollowers: { [weak self] userId in
                self?.showFollowers(for: userId)
            },
            onShowFollowing: { [weak self] userId in
                self?.showFollowing(for: userId)
            },
            onConnectTapped: { [weak self] userId, firstName, isPrivate in
                self?.showConnect(userId: userId, firstName: firstName, isPrivate: isPrivate)
            }
        )

        return NavigationStack {
            ProfileView(
                viewModel: viewModel,
                userId: userId,
                coordinator: self
            )
        }
    }
    
    /// Builds the FollowersListView
    func makeFollowersView() -> some View {
        guard let coordinator = followersCoordinator else {
            return AnyView(EmptyView())
        }
        return AnyView(coordinator.start())
    }
    
    /// Builds the FollowingListView
    func makeFollowingView() -> some View {
        guard let coordinator = followingCoordinator else {
            return AnyView(EmptyView())
        }
        return AnyView(coordinator.start())
    }
    
    /// Builds the ConnectView
    func makeConnectView() -> some View {
        guard let coordinator = connectCoordinator else {
            return AnyView(EmptyView())
        }
        return AnyView(coordinator.start())
    }
}
