//
//  ProfileCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

final class ProfileCoordinator {
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    func start() -> some View {
        NavigationStack {
            let viewModel = ProfileViewModel()
            ProfileView(viewModel: viewModel, userId: userId)
        }
    }
}
