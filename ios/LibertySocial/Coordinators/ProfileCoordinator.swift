//
//  ProfileCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

@MainActor
final class ProfileCoordinator {
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
        let model = ProfileModel()
        let viewModel = ProfileViewModel(
            model: model,
            makeMediaVM: { key in
                let mediaModel = MediaModel(TokenProvider: self.tokenProvider)
                return MediaViewModel(mediaKey: key, model: mediaModel) // keep your init order
            },
            authenticationManager: authenticationManager
        )

        return NavigationStack {
            ProfileView(
                viewModel: viewModel,
                userId: userId,
                makeFollowersCoordinator: { id in
                    FollowersListCoordinator(
                        userId: id,
                        authenticationManager: self.authenticationManager,
                        tokenProvider: self.tokenProvider
                    )
                },
                makeFollowingCoordinator: { id in
                    FollowingListCoordinator(
                        userId: id,
                        authenticationManager: self.authenticationManager,
                        tokenProvider: self.tokenProvider
                    )
                }
            )
        }
    }
}
