//
//  AddSubnetMembersCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-01-28.
//

import SwiftUI

final class AddSubnetMembersCoordinator {
    private let authSession: AuthSession
    private let authService: AuthServiceProtocol
    private let subnetId: String
    private let onMembersAdded: () -> Void
    
    init(subnetId: String,
         onMembersAdded: @escaping () -> Void,
         authSession: AuthSession = AuthService.shared,
         authService: AuthServiceProtocol = AuthService.shared) {
        self.subnetId = subnetId
        self.onMembersAdded = onMembersAdded
        self.authSession = authSession
        self.authService = authService
    }
    
    func start() -> some View {
        let model = AddSubnetMembersModel(authSession: authSession)
        let viewModel = AddSubnetMembersViewModel(model: model)
        return AddSubnetMembersView(viewModel: viewModel, subnetId: subnetId, onMembersAdded: onMembersAdded)
    }
}
