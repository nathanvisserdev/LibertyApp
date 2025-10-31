//
//  ConnectCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-01-28.
//

import SwiftUI

final class ConnectCoordinator {
    private let authSession: AuthSession
    private let authService: AuthServiceProtocol
    private let firstName: String
    private let userId: String
    private let isPrivate: Bool
    
    init(firstName: String,
         userId: String,
         isPrivate: Bool,
         authSession: AuthSession = AuthService.shared,
         authService: AuthServiceProtocol = AuthService.shared) {
        self.firstName = firstName
        self.userId = userId
        self.isPrivate = isPrivate
        self.authSession = authSession
        self.authService = authService
    }
    
    func start() -> some View {
        let model = ConnectModel(authService: authService)
        let viewModel = ConnectViewModel(model: model, userId: userId)
        return ConnectView(viewModel: viewModel, firstName: firstName, userId: userId, isPrivate: isPrivate)
    }
}
