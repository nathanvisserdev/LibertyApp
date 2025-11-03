//
//  FeedView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-09.
//

import SwiftUI
import Combine

struct FeedView: View {
    @StateObject private var vm: FeedViewModel
    @EnvironmentObject private var session: SessionStore
    
    init(viewModel: FeedViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading && vm.items.isEmpty {
                    ProgressView("Loading…")
                } else if let err = vm.error {
                    VStack(spacing: 12) {
                        Text(err).foregroundStyle(.red)
                        Button("Retry") { Task { await vm.load() } }
                    }
                } else {
                    List {
                        if !vm.mine.isEmpty          { Section("Your posts") { rows(vm.mine) } }
                        if !vm.acquaintances.isEmpty { Section("Acquaintances") { rows(vm.acquaintances) } }
                        if !vm.strangers.isEmpty     { Section("Strangers") { rows(vm.strangers) } }
                        if !vm.following.isEmpty     { Section("Following") { rows(vm.following) } }
                    }
                    .listStyle(.insetGrouped)
                    .refreshable { await vm.refresh() }
                }
            }
            .navigationTitle("Feed")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Log out") {
                        AuthService.shared.deleteToken()
                        Task {
                            await session.refresh()
                        }
                    }
                }
            }
        }
        .task { await vm.load() }
        .safeAreaInset(edge: .bottom) {
            TabBarCoordinator().start()
                .ignoresSafeArea(edges: .bottom)
        }
    }

    @ViewBuilder private func rows(_ items: [FeedItem]) -> some View {
        ForEach(items, id: \.id) { item in
            PostView(viewModel: PostViewModel(
                post: PostItem(from: item),
                currentUserId: item.userId,
                showMenu: vm.isUsersPost(item)
            ))
        }
    }
}
