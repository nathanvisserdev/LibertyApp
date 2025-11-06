//
//  TabView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-10.
//

import SwiftUI

struct TabBarView: View {
    @StateObject private var viewModel: TabBarViewModel
    @ObservedObject private var tabBarCoordinator: TabBarCoordinator
    @ObservedObject private var notificationsMenuCoordinator: NotificationsMenuCoordinator
    @ObservedObject private var networkMenuCoordinator: NetworkMenuCoordinator
    @ObservedObject private var searchCoordinator: SearchCoordinator
    @ObservedObject private var profileMenuCoordinator: ProfileMenuCoordinator

    init(
        viewModel: TabBarViewModel,
        tabBarCoordinator: TabBarCoordinator,
        notificationsMenuCoordinator: NotificationsMenuCoordinator,
        networkMenuCoordinator: NetworkMenuCoordinator,
        searchCoordinator: SearchCoordinator,
        profileMenuCoordinator: ProfileMenuCoordinator
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.tabBarCoordinator = tabBarCoordinator
        self.notificationsMenuCoordinator = notificationsMenuCoordinator
        self.networkMenuCoordinator = networkMenuCoordinator
        self.searchCoordinator = searchCoordinator
        self.profileMenuCoordinator = profileMenuCoordinator
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
        .sheet(isPresented: $notificationsMenuCoordinator.isShowingNotifications) {
            notificationsMenuCoordinator.makeView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $networkMenuCoordinator.isShowingNetworkMenu) {
            networkMenuCoordinator.makeView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $searchCoordinator.isShowingSearch) {
            searchCoordinator.makeView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $profileMenuCoordinator.isShowingProfile) {
            profileMenuCoordinator.makeView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $tabBarCoordinator.isShowingCreatePost) {
            tabBarCoordinator.makeCreatePostView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}
