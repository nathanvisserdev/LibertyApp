//
//  SearchCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI
import Combine

/// Coordinator for Search flow
@MainActor
final class SearchCoordinator: ObservableObject {
    
    // MARK: - Published State
    @Published var isShowingSearch: Bool = false
    @Published var isShowingProfile: Bool = false
    
    // MARK: - Private State
    private var selectedUserId: String?
    
    // MARK: - Child Coordinators
    private var profileCoordinator: ProfileCoordinator?
    
    // MARK: - Dependencies
    private let authenticationManager: AuthManaging
    private let tokenProvider: TokenProviding

    init(authenticationManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.authenticationManager = authenticationManager
        self.tokenProvider = tokenProvider
    }
    
    // MARK: - Public Methods
    
    /// Presents the SearchView
    func showSearch() {
        isShowingSearch = true
    }
    
    /// Presents a profile for the specified user
    func showProfile(for userId: String) {
        selectedUserId = userId
        profileCoordinator = ProfileCoordinator(
            userId: userId,
            authenticationManager: authenticationManager,
            tokenProvider: tokenProvider
        )
        isShowingProfile = true
    }

    /// Builds the SearchView with its ViewModel
    func makeView() -> some View {
        let viewModel = SearchViewModel(
            onUserSelected: { [weak self] userId in
                self?.showProfile(for: userId)
            }
        )
        return SearchView(
            viewModel: viewModel,
            coordinator: self
        )
    }
    
    /// Builds the ProfileView for the selected user
    func makeProfileView() -> some View {
        guard let coordinator = profileCoordinator else {
            return AnyView(EmptyView())
        }
        return AnyView(coordinator.start())
    }
}
