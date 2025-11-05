//
//  ProfileMenuCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

@MainActor
final class ProfileMenuCoordinator {
    // MARK: - Dependencies
    private let authenticationManager: AuthManaging
    private let tokenProvider: TokenProviding

    // MARK: - Init
    init(authenticationManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.authenticationManager = authenticationManager
        self.tokenProvider = tokenProvider
    }
    
    // MARK: - Start
    func start(userId: String?) -> some View {
        let viewModel = ProfileMenuViewModel()
        return ProfileMenuView(
            viewModel: viewModel,
            userId: userId,
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
