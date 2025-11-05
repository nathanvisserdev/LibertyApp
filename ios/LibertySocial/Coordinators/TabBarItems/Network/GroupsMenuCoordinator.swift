//
//  GroupsMenuCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

@MainActor
final class GroupsMenuCoordinator {
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
    func start() -> some View {
        let viewModel = GroupsMenuViewModel()
        return GroupsMenuView(viewModel: viewModel)
    }
}
