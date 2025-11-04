//
//  FeedView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-09.
//

import SwiftUI
import Combine

struct FeedView: View {
    @ObservedObject var viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.items.isEmpty {
                ProgressView("Loading…")
            } else if let err = viewModel.error {
                VStack(spacing: 12) {
                    Text(err).foregroundStyle(.red)
                    Button("Retry") { Task { await viewModel.load() } }
                }
            } else {
                List {
                    if !viewModel.mine.isEmpty          { Section("Your posts") { rows(viewModel.mine) } }
                    if !viewModel.acquaintances.isEmpty { Section("Acquaintances") { rows(viewModel.acquaintances) } }
                    if !viewModel.strangers.isEmpty     { Section("Strangers") { rows(viewModel.strangers) } }
                    if !viewModel.following.isEmpty     { Section("Following") { rows(viewModel.following) } }
                }
                .listStyle(.insetGrouped)
                .refreshable { await viewModel.refresh() }
            }
        }
        .navigationTitle("Feed")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Log out") {
                    viewModel.logoutTapped()
                }
            }
        }
        .task { await viewModel.load() }
    }

    @ViewBuilder private func rows(_ items: [FeedItem]) -> some View {
        ForEach(items, id: \.id) { item in
            PostRowView(
                post: PostItem(from: item),
                currentUserId: item.userId,
                showMenu: viewModel.isUsersPost(item),
                makeMediaVM: viewModel.makeMediaViewModel(for:),
                thread: viewModel.bindThread(for: item.postId),
                onToggleComments: { viewModel.toggleComments(for: item.postId) },
                onChangeInput: { viewModel.updateInput(for: item.postId, to: $0) },
                onSubmitComment: { Task { await viewModel.submitComment(for: item.postId) } }
            )
        }
    }
}
