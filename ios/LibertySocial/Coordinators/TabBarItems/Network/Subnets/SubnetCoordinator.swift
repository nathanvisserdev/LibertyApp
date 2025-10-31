//
//  SubnetCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-01-28.
//

import SwiftUI

final class SubnetCoordinator {
    private let authSession: AuthSession
    private let authService: AuthServiceProtocol
    private let subnetListViewModel: SubnetListViewModel
    
    init(subnetListViewModel: SubnetListViewModel,
         authSession: AuthSession = AuthService.shared,
         authService: AuthServiceProtocol = AuthService.shared) {
        self.subnetListViewModel = subnetListViewModel
        self.authSession = authSession
        self.authService = authService
    }
    
    func start() -> some View {
        let model = SubnetModel(authSession: authSession)
        let viewModel = SubnetViewModel(model: model)
        return SubnetView(viewModel: viewModel, subnetListViewModel: subnetListViewModel)
    }
}
