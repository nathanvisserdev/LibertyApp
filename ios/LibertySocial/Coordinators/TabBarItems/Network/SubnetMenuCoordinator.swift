//
//  SubnetMenuCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI
import Combine

/// Coordinator for SubnetMenu flow
@MainActor
final class SubnetMenuCoordinator: ObservableObject {
    
    // MARK: - Published State
    @Published var isShowingSubnetMenu: Bool = false
    
    // MARK: - Dependencies
    private let authenticationManager: AuthManaging
    private let tokenProvider: TokenProviding

    // MARK: - Init
    init(authenticationManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.authenticationManager = authenticationManager
        self.tokenProvider = tokenProvider
    }
    
    // MARK: - Public Methods
    
    /// Presents the SubnetMenuView
    func showSubnetMenu() {
        isShowingSubnetMenu = true
    }

    /// Builds the SubnetMenuView with its ViewModel
    func makeView() -> some View {
        let viewModel = SubnetMenuViewModel()
        return SubnetMenuView(viewModel: viewModel)
    }
}
