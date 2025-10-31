//
//  SignupCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import SwiftUI

final class SignupCoordinator {
    
    // MARK: - Init
    init() {
        // Initialize with dependencies if needed
    }
    
    // MARK: - Start
    /// Builds the SignupFlowView with its ViewModel
    func start() -> some View {
        let viewModel = SignupViewModel()
        return SignupFlowView(viewModel: viewModel)
    }
}
