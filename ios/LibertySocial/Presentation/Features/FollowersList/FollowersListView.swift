//
//  FollowersListView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

struct FollowersListView: View {
    @StateObject private var viewModel: FollowersListViewModel

    init(viewModel: FollowersListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Loading followers...")
            } else if let errorMessage = viewModel.errorMessage {
                errorView(message: errorMessage)
            } else if viewModel.followers.isEmpty {
                emptyStateView
            } else {
                followersList
            }
        }
        .navigationTitle("Followers")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.fetchFollowers() }
    }
    
    // MARK: - Subviews
    private var followersList: some View {
        List(viewModel.followers) { follower in
            Button {
                viewModel.selectUser(follower.id)
            } label: {
                FollowerRow(follower: follower)
            }
            .buttonStyle(.plain)
        }
        .listStyle(.plain)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No Followers").font(.headline)
            Text("This user doesn't have any followers yet.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            Text("Error").font(.headline)
            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Try Again") { Task { await viewModel.fetchFollowers() } }
                .buttonStyle(.bordered)
        }
        .padding()
    }
}

// MARK: - Follower Row
struct FollowerRow: View {
    let follower: FollowerUser
    var body: some View {
        HStack(spacing: 12) {
            if let photoKey = follower.profilePhoto, !photoKey.isEmpty {
                ProfilePhotoView(photoKey: photoKey)
                    .frame(width: 50, height: 50)
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.gray)
                    )
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("\(follower.firstName) \(follower.lastName)").font(.body).fontWeight(.medium)
                Text("@\(follower.username)").font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
