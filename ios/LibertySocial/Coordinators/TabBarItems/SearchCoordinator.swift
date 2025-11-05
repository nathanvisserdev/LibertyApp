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

    /// Builds the SearchView with its ViewModel
    func makeView() -> some View {
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
