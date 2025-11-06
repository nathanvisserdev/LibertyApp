//
//  RootView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-07.
//

import SwiftUI

struct RootView: View {
    @StateObject private var viewModel: RootViewModel
    private let tabBarCoordinator: TabBarCoordinator
    private let loginCoordinator: LoginCoordinator

    init(viewModel: RootViewModel,
         tabBarCoordinator: TabBarCoordinator,
         loginCoordinator: LoginCoordinator) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.tabBarCoordinator = tabBarCoordinator
        self.loginCoordinator = loginCoordinator
    }

    var body: some View {
        Group {
            if viewModel.isAuthenticated {
                tabBarCoordinator.start()
            } else {
                loginCoordinator.start()
            }
        }
    }
}
