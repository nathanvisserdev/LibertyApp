//
//  TabView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-10.
//

import SwiftUI

struct TabBarView: View {
    @StateObject private var viewModel: TabBarViewModel
    private let makeNetworkMenuCoordinator: () -> NetworkMenuCoordinator
    private let makeProfileMenuCoordinator: () -> ProfileMenuCoordinator
    private let makeSearchCoordinator: () -> SearchCoordinator

    init(
        viewModel: TabBarViewModel,
        makeNetworkMenuCoordinator: @escaping () -> NetworkMenuCoordinator,
        makeProfileMenuCoordinator: @escaping () -> ProfileMenuCoordinator,
        makeSearchCoordinator: @escaping () -> SearchCoordinator
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.makeNetworkMenuCoordinator = makeNetworkMenuCoordinator
        self.makeProfileMenuCoordinator = makeProfileMenuCoordinator
        self.makeSearchCoordinator = makeSearchCoordinator
    }

    var body: some View {
        HStack {
            Spacer(minLength: 0)
            Button { viewModel.tapNotifications() } label: {
                Image(systemName: "bell").font(.system(size: 28, weight: .regular)).foregroundColor(.primary)
            }
            Spacer(minLength: 0)
            Button { viewModel.tapNetworkMenu() } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "person.3").font(.system(size: 28, weight: .regular)).foregroundColor(.primary)
                }
            }
            Spacer(minLength: 0)
            Button { viewModel.tapCompose() } label: {
                Image(systemName: "square.and.arrow.up").font(.system(size: 28, weight: .regular)).foregroundColor(.primary)
            }
            .accessibilityLabel("Compose")
            Spacer(minLength: 0)
            Button { viewModel.tapSearch() } label: {
                Image(systemName: "magnifyingglass").font(.system(size: 28, weight: .regular)).foregroundColor(.primary)
            }
            Spacer(minLength: 0)
            Button { viewModel.tapCurrentUserProfile() } label: {
                Image(systemName: "person").font(.system(size: 28, weight: .regular)).foregroundColor(.primary)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .task { await viewModel.fetchCurrentUserInfo() }
        .sheet(isPresented: $viewModel.isShowingCompose) {
            CreatePostCoordinator().start()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.isShowingSearch) {
            makeSearchCoordinator().start()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.isShowingNotifications) {
            NotificationsMenuCoordinator().start()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.isShowingNetworkMenu) {
            makeNetworkMenuCoordinator().start()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.isShowingProfile) {
            if let userId = viewModel.selectedUserId {
                makeProfileMenuCoordinator().start(userId: userId)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

