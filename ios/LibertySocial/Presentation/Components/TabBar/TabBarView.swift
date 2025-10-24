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
    @AppStorage("newConnectionRequest") private var newConnectionRequest: Bool = true

    var body: some View {
        let _ = print("🔔 TabBarView - newConnectionRequest: \(newConnectionRequest)")
        HStack {
            Spacer(minLength: 0)
            Button {
                Task { await feedViewModel.refresh() }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(.primary)
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
                    
                    if newConnectionRequest {
                        Image(systemName: "bell.circle")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.red)
                            .offset(x: 8, y: -8)
                    }
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
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(.primary)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
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
        .onReceive(NotificationCenter.default.publisher(for: .connectionRequestReceived)) { _ in
            // Update badge when notification received
            newConnectionRequest = true
        }
    }
}
