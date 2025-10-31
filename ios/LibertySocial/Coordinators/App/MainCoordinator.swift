//
//  MainCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-01-28.
//

import SwiftUI

final class MainCoordinator {
    private let authSession: AuthSession
    private let authService: AuthServiceProtocol
    
    init(authSession: AuthSession = AuthService.shared,
         authService: AuthServiceProtocol = AuthService.shared) {
        self.authSession = authSession
        self.authService = authService
    }
    
    func start() -> some View {
        let model = MainModel(authSession: authSession)
        let viewModel = MainViewModel(model: model)
        return MainView(viewModel: viewModel)
    }
}
