//
//  SearchCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

@MainActor
final class SearchCoordinator {
    private let authenticationManager: AuthManaging
    private let tokenProvider: TokenProviding

    init(authenticationManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.authenticationManager = authenticationManager
        self.tokenProvider = tokenProvider
    }

    func start() -> some View {
        let viewModel = SearchViewModel()
        return SearchView(
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
