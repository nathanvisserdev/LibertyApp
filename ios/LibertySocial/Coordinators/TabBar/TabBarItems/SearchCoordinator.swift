//
//  SearchCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI
import Combine

@MainActor
final class SearchCoordinator: ObservableObject {
    @Published var isShowingSearch: Bool = false
    
    private var selectedUserId: String?
    private var profileCoordinator: ProfileCoordinator?
    private let authenticationManager: AuthManaging
    private let tokenProvider: TokenProviding

    init(authenticationManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.authenticationManager = authenticationManager
        self.tokenProvider = tokenProvider
    }
    
    func showSearch() {
        isShowingSearch = true
    }
    
    func showProfile(for userId: String) {
        selectedUserId = userId
        profileCoordinator = ProfileCoordinator(
            userId: userId,
            authenticationManager: authenticationManager,
            tokenProvider: tokenProvider
        )
    }

    func makeView() -> some View {
        let model = SearchModel()
        let viewModel = SearchViewModel(
            model: model,
            onUserSelected: { [weak self] userId in
                self?.showProfile(for: userId)
            }
        )
        
        viewModel.onShowProfile = { [weak self] in
            guard let self = self,
                  let coordinator = self.profileCoordinator else {
                return AnyView(EmptyView())
            }
            return AnyView(coordinator.start())
        }
        
        return SearchView(viewModel: viewModel)
    }
}
