//
//  FeedView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-09.
//

import SwiftUI

struct FeedView: View {
    @StateObject private var vm = FeedViewModel()
    @EnvironmentObject private var session: SessionStore
    @StateObject private var tabBarVM = TabBarViewModel() // controls compose sheet via TabBarView

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
                        AuthService.logout()
                        session.refresh()
                    }
                }
            }
        }
        .task { await vm.load() }
        .safeAreaInset(edge: .bottom) {
            TabBarView(viewModel: tabBarVM) // presents CreatePostView internally
                .ignoresSafeArea(edges: .bottom)
        }
    }

    @ViewBuilder private func rows(_ items: [FeedItem]) -> some View {
        ForEach(items, id: \.id) { item in
            VStack(alignment: .leading, spacing: 6) {
                Text(item.user.email).font(.footnote).foregroundStyle(.secondary)
                Text(item.content).font(.body)
                Text(DateFormatter.feed.string(fromISO: item.createdAt))
                    .font(.caption2).foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
}

private extension DateFormatter {
    static let feed: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f
    }()

    func string(fromISO s: String) -> String {
        let iso = ISO8601DateFormatter()
        return string(from: iso.date(from: s) ?? Date())
    }
}


