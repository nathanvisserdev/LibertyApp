//
//  FollowersListCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI
import Combine

// MARK: - FollowersListRoute
enum FollowersListRoute: Hashable {
    case profile(String)
}

// MARK: - FollowersNavPathStore
final class FollowersNavPathStore: ObservableObject {
    @Published var path = NavigationPath()
}

@MainActor
final class FollowersListCoordinator: ObservableObject {
    // MARK: - Navigation
    private let nav = FollowersNavPathStore()
    
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

    /// For standalone presentation (e.g., from sheets or modal contexts)
    func start() -> some View {
        FollowersStackView(
            nav: nav,
            userId: userId,
            authenticationManager: authenticationManager,
            tokenProvider: tokenProvider,
            onUserSelected: { [weak self] id in
                self?.openProfile(id)
            }
        )
    }
    
    /// For use within an existing NavigationStack (e.g., from ProfileCoordinator)
    func makeView(onUserSelected: @escaping (String) -> Void) -> some View {
        let model = FollowersListModel()
        let viewModel = FollowersListViewModel(
            model: model,
            userId: userId,
            onUserSelected: onUserSelected
        )
        return FollowersListView(viewModel: viewModel)
    }
    
    // MARK: - Navigation Actions
    func openProfile(_ id: String) {
        nav.path.append(FollowersListRoute.profile(id))
    }
}

// MARK: - FollowersStackView
struct FollowersStackView: View {
    @ObservedObject var nav: FollowersNavPathStore
    let userId: String
    let authenticationManager: AuthManaging
    let tokenProvider: TokenProviding
    let onUserSelected: (String) -> Void
    
    var body: some View {
        NavigationStack(
            path: Binding(
                get: { nav.path },
                set: { nav.path = $0 }
            )
        ) {
            makeFollowersListView()
                .navigationDestination(for: FollowersListRoute.self) { route in
                    switch route {
                    case .profile(let id):
                        ProfileCoordinator(
                            userId: id,
                            authenticationManager: authenticationManager,
                            tokenProvider: tokenProvider
                        ).start()
                    }
                }
        }
    }
    
    private func makeFollowersListView() -> some View {
        let model = FollowersListModel()
        let viewModel = FollowersListViewModel(
            model: model,
            userId: userId,
            onUserSelected: onUserSelected
        )
        return FollowersListView(viewModel: viewModel)
    }
}
