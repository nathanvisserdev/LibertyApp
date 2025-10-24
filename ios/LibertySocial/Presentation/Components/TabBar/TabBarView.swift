//
//  TabView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-10.
//

import SwiftUI

struct TabBarView: View {
    @ObservedObject var viewModel: TabBarViewModel
    @ObservedObject var feedViewModel: FeedViewModel
    @AppStorage("newConnectionRequest") private var newConnectionRequest: Bool = false

    var body: some View {
        let _ = print("🔔 TabBarView - newConnectionRequest: \(newConnectionRequest)")
        HStack {
            Spacer(minLength: 0)
            Button {
                viewModel.showNotifications()
            } label: {
                Image(systemName: newConnectionRequest ? "bell.and.waves.left.and.right.fill" : "bell")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(newConnectionRequest ? .red : .primary)
            }
            Spacer(minLength: 0)
            Button {
                // Action for group/sequence - show connection requests
                viewModel.showConnectionRequests()
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "person.3.sequence")
                        .font(.system(size: 28, weight: .regular))
                        .foregroundColor(.primary)
                }
            }
            Spacer(minLength: 0)
            Button {
                viewModel.showCompose()
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(.primary)
            }
            .accessibilityLabel("Compose")
            Spacer(minLength: 0)
            Button {
                viewModel.showSearch()
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(.primary)
            }
            Spacer(minLength: 0)
            Button {
                // Action for profile
            } label: {
                if let photoKey = viewModel.currentUserPhotoKey {
                    ProfilePhotoView(photoKey: photoKey)
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 28, weight: .regular))
                        .foregroundColor(.primary)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .task {
            // Fetch current user's photo when tab bar appears
            await viewModel.fetchCurrentUserPhoto()
        }
        .sheet(
            isPresented: Binding(
                get: { viewModel.isShowingCompose },
                set: { viewModel.isShowingCompose = $0 }
            )
        ) {
            CreatePostView(
                vm: CreatePostViewModel(),
                onCancel: { viewModel.hideCompose() },
                onPosted: { viewModel.hideCompose() }
            )
        }
        .sheet(
            isPresented: Binding(
                get: { viewModel.isShowingSearch },
                set: { viewModel.isShowingSearch = $0 }
            )
        ) {
            SearchView(viewModel: SearchViewModel())
        }
        .sheet(
            isPresented: Binding(
                get: { viewModel.isShowingConnectionRequests },
                set: { viewModel.isShowingConnectionRequests = $0 }
            )
        ) {
            ConnectionRequestsView(onDismiss: {
                viewModel.hideConnectionRequests()
                // Clear badge when viewing requests
                newConnectionRequest = false
            })
        }
        .sheet(
            isPresented: Binding(
                get: { viewModel.isShowingNotifications },
                set: { viewModel.isShowingNotifications = $0 }
            )
        ) {
            NotificationsView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .connectionRequestReceived)) { _ in
            // Update badge when notification received
            newConnectionRequest = true
        }
    }
}
