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
    @EnvironmentObject private var session: SessionStore

    init(viewModel: RootViewModel, tabBarCoordinator: TabBarCoordinator) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.tabBarCoordinator = tabBarCoordinator
    }

    var body: some View {
        NavigationStack {
            // Gate by auth if you have it; otherwise always show the authenticated area
            if session.isAuthenticated {
                tabBarCoordinator.start()
            } else {
                // Replace with your unauthenticated flow coordinator when ready
                Text("Sign in flow")
            }
        }
    }
}

