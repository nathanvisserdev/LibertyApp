//
//  FeedCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-01-28.
//

import SwiftUI

final class FeedCoordinator {
    private let authSession: AuthSession
    private let authService: AuthServiceProtocol
    
    init(authSession: AuthSession = AuthService.shared,
         authService: AuthServiceProtocol = AuthService.shared) {
        self.authSession = authSession
        self.authService = authService
    }
    
    func start() -> some View {
        let model = FeedModel(authService: authService)
        let viewModel = FeedViewModel(model: model)
        return FeedView(viewModel: viewModel)
    }
}
