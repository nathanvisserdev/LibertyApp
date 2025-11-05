//
//  FollowersListCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

@MainActor
final class FollowersListCoordinator {
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

    func start() -> some View {
        let model = FollowersListModel()
        let viewModel = FollowersListViewModel(model: model, userId: userId)
        return FollowersListView(
            viewModel: viewModel,
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
