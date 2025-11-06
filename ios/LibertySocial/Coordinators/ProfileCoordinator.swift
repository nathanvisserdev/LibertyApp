//
//  ProfileCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI
import Combine

// MARK: - Navigation Path Store
final class ProfileNavPathStore: ObservableObject {
    @Published var path = NavigationPath()
}

// MARK: - Route Enum
enum ProfileRoute: Hashable {
    case followers(String)
    case following(String)
}

// MARK: - Profile Stack View
struct ProfileStackView: View {
    @ObservedObject var nav: ProfileNavPathStore
    @StateObject var viewModel: ProfileViewModel
    let userId: String
    @ObservedObject var coordinator: ProfileCoordinator
    
    var body: some View {
        NavigationStack(path: Binding(
            get: { nav.path },
            set: { nav.path = $0 }
        )) {
            ProfileView(
                viewModel: viewModel,
                userId: userId,
                coordinator: coordinator
            )
            .navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                case .followers(let id):
                    coordinator.makeFollowersCoordinator(for: id)
                        .makeView(onUserSelected: { userId in
                            coordinator.showChildProfile(for: userId)
                        })
                case .following(let id):
                    coordinator.makeFollowingCoordinator(for: id)
                        .makeView(onUserSelected: { userId in
                            coordinator.showChildProfile(for: userId)
                        })
                }
            }
            .sheet(isPresented: $coordinator.isShowingChildProfile) {
                coordinator.makeChildProfileView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

@MainActor
final class ProfileCoordinator: ObservableObject {
    
    // MARK: - Navigation
    private let nav = ProfileNavPathStore()
    
    // MARK: - Published State
    @Published var isShowingConnect: Bool = false
    @Published var isShowingChildProfile: Bool = false
    
    // MARK: - Child Coordinators
    private var connectCoordinator: ConnectCoordinator?
    private var childProfileCoordinator: ProfileCoordinator?
    
    // MARK: - Private State
    private var selectedUserId: String?
    
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
    
    /// Opens the followers list for the specified user
    func openFollowers(of userId: String) {
        nav.path.append(ProfileRoute.followers(userId))
    }
    
    /// Opens the following list for the specified user
    func openFollowing(of userId: String) {
        nav.path.append(ProfileRoute.following(userId))
    }
    
    /// Presents a child profile for the specified user (via sheet)
    func showChildProfile(for userId: String) {
        selectedUserId = userId
        childProfileCoordinator = ProfileCoordinator(
            userId: userId,
            authenticationManager: authenticationManager,
            tokenProvider: tokenProvider
        )
        isShowingChildProfile = true
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
                self?.openFollowers(of: userId)
            },
            onShowFollowing: { [weak self] userId in
                self?.openFollowing(of: userId)
            },
            onConnectTapped: { [weak self] userId, firstName, isPrivate in
                self?.showConnect(userId: userId, firstName: firstName, isPrivate: isPrivate)
            }
        )

        return ProfileStackView(
            nav: nav,
            viewModel: viewModel,
            userId: userId,
            coordinator: self
        )
    }
    
    /// Creates a FollowersListCoordinator for the given user
    func makeFollowersCoordinator(for userId: String) -> FollowersListCoordinator {
        return FollowersListCoordinator(
            userId: userId,
            authenticationManager: authenticationManager,
            tokenProvider: tokenProvider
        )
    }
    
    /// Creates a FollowingListCoordinator for the given user
    func makeFollowingCoordinator(for userId: String) -> FollowingListCoordinator {
        return FollowingListCoordinator(
            userId: userId,
            authenticationManager: authenticationManager,
            tokenProvider: tokenProvider
        )
    }
    
    /// Builds the child ProfileView for the selected user
    func makeChildProfileView() -> some View {
        guard let coordinator = childProfileCoordinator else {
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
