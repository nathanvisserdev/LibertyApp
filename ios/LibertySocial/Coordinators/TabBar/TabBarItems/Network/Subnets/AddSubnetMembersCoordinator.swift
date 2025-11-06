//
//  AddSubnetMembersCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-01-28.
//

import SwiftUI

final class AddSubnetMembersCoordinator {
    private let TokenProvider: TokenProviding
    private let AuthManager: AuthManaging
    private let subnetId: String
    
    init(subnetId: String,
         TokenProvider: TokenProviding = AuthService.shared,
         AuthManager: AuthManaging = AuthService.shared) {
        self.subnetId = subnetId
        self.TokenProvider = TokenProvider
        self.AuthManager = AuthManager
    }
    
    func start() -> some View {
        let model = AddSubnetMembersModel(TokenProvider: TokenProvider)
        let viewModel = AddSubnetMembersViewModel(model: model)
        return AddSubnetMembersView(viewModel: viewModel, subnetId: subnetId)
    }
}
