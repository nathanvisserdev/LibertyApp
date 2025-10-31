//
//  SubnetCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-01-28.
//

import SwiftUI

final class SubnetCoordinator {
    private let authSession: AuthSession
    private let subnet: Subnet
    
    init(subnet: Subnet,
         authSession: AuthSession = AuthService.shared) {
        self.subnet = subnet
        self.authSession = authSession
    }
    
    func start() -> some View {
        let model = SubnetModel(authSession: authSession)
        let viewModel = SubnetViewModel(model: model, subnet: subnet)
        return SubnetView(viewModel: viewModel)
    }
}
