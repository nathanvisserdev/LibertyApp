//
//  SubnetCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-01-28.
//

import SwiftUI

final class SubnetCoordinator {
    private let TokenProvider: TokenProviding
    private let subnet: Subnet
    
    init(subnet: Subnet,
         TokenProvider: TokenProviding = AuthService.shared) {
        self.subnet = subnet
        self.TokenProvider = TokenProvider
    }
    
    func start() -> some View {
        let model = SubnetModel(TokenProvider: TokenProvider)
        let viewModel = SubnetViewModel(model: model, subnet: subnet)
        return SubnetView(viewModel: viewModel)
    }
}
