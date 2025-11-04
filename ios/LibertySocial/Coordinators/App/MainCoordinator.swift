//
//  MainCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-01-28.
//

import SwiftUI

final class MainCoordinator {
    private let TokenProvider: TokenProviding
    private let AuthManager: AuthManaging
    
    init(TokenProvider: TokenProviding = AuthService.shared,
         AuthManager: AuthManaging = AuthService.shared) {
        self.TokenProvider = TokenProvider
        self.AuthManager = AuthManager
    }
    
    func start() -> some View {
        let model = MainModel(TokenProvider: TokenProvider)
        let viewModel = MainViewModel(model: model)
        return MainView(viewModel: viewModel)
    }
}
