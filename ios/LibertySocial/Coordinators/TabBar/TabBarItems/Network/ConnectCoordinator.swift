//
//  ConnectCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-01-28.
//

import SwiftUI

final class ConnectCoordinator {
    private let TokenProvider: TokenProviding
    private let AuthManager: AuthManaging
    private let firstName: String
    private let userId: String
    private let isPrivate: Bool
    
    init(firstName: String,
         userId: String,
         isPrivate: Bool,
         TokenProvider: TokenProviding = AuthService.shared,
         AuthManager: AuthManaging = AuthService.shared) {
        self.firstName = firstName
        self.userId = userId
        self.isPrivate = isPrivate
        self.TokenProvider = TokenProvider
        self.AuthManager = AuthManager
    }
    
    func start() -> some View {
        let model = ConnectModel(AuthManager: AuthManager)
        let viewModel = ConnectViewModel(model: model, userId: userId)
        return ConnectView(viewModel: viewModel, firstName: firstName, userId: userId, isPrivate: isPrivate)
    }
}
