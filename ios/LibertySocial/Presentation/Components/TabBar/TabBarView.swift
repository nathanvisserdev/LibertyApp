//
//  TabView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-10.
//

import SwiftUI

struct TabBarView: View {
    @ObservedObject var viewModel: TabBarViewModel
    @ObservedObject var coordinator: TabBarCoordinator
    @ObservedObject var feedViewModel: FeedViewModel

    var body: some View {
        HStack {
            Spacer(minLength: 0)
            Button {
                coordinator.showNotifications()
            } label: {
                Image(systemName: "bell")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(.primary)
            }
            Spacer(minLength: 0)
            Button {
                coordinator.showGroups()
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "person.3.sequence")
                        .font(.system(size: 28, weight: .regular))
                        .foregroundColor(.primary)
                }
            }
            Spacer(minLength: 0)
            Button {
                coordinator.showCompose()
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(.primary)
            }
            .accessibilityLabel("Compose")
            Spacer(minLength: 0)
            Button {
                coordinator.showSearch()
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(.primary)
            }
            Spacer(minLength: 0)
            Button {
                coordinator.showCurrentUserProfile()
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
            // Fetch current user's info when tab bar appears
            await viewModel.fetchCurrentUserInfo()
        }
        .sheet(
            isPresented: Binding(
                get: { coordinator.isShowingCompose },
                set: { coordinator.isShowingCompose = $0 }
            )
        ) {
            CreatePostView(
                vm: CreatePostViewModel(),
                onCancel: { coordinator.hideCompose() },
                onPosted: { coordinator.hideCompose() }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(
            isPresented: Binding(
                get: { coordinator.isShowingSearch },
                set: { coordinator.isShowingSearch = $0 }
            )
        ) {
            SearchView(viewModel: SearchViewModel())
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(
            isPresented: Binding(
                get: { coordinator.isShowingNotifications },
                set: { coordinator.isShowingNotifications = $0 }
            )
        ) {
            NotificationsView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(
            isPresented: Binding(
                get: { coordinator.isShowingGroups },
                set: { coordinator.isShowingGroups = $0 }
            )
        ) {
            GroupsView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(
            isPresented: Binding(
                get: { coordinator.isShowingProfile },
                set: { coordinator.isShowingProfile = $0 }
            )
        ) {
            if let userId = coordinator.selectedUserId {
                ProfileView(viewModel: ProfileViewModel(), userId: userId)
            }
        }
    }
}
