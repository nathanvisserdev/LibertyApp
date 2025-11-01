//
//  FollowingListView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

struct FollowingListView: View {
    @StateObject private var viewModel: FollowingListViewModel
    
    init(viewModel: FollowingListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Loading following...")
            } else if let errorMessage = viewModel.errorMessage {
                errorView(message: errorMessage)
            } else if viewModel.following.isEmpty {
                emptyStateView
            } else {
                followingList
            }
        }
        .navigationTitle("Following")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchFollowing()
        }
    }
    
    // MARK: - Subviews
    
    private var followingList: some View {
        List(viewModel.following) { user in
            NavigationLink(destination: {
                let coordinator = ProfileCoordinator(userId: user.id)
                coordinator.start()
            }) {
                FollowingRow(user: user)
            }
        }
        .listStyle(.plain)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("Not Following Anyone")
                .font(.headline)
            Text("This user isn't following anyone yet.")
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
            Text("Error")
                .font(.headline)
            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Try Again") {
                Task {
                    await viewModel.fetchFollowing()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

// MARK: - Following Row Component
struct FollowingRow: View {
    let user: FollowingUser
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Photo
            if let photoKey = user.profilePhoto, !photoKey.isEmpty {
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
                Text("\(user.firstName) \(user.lastName)")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("@\(user.username)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

#Preview {
    let model = FollowingListModel()
    let viewModel = FollowingListViewModel(model: model, userId: "preview-user-id")
    return NavigationStack {
        FollowingListView(viewModel: viewModel)
    }
}
