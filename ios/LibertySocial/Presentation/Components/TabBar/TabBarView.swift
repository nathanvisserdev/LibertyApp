//
//  TabView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-10.
//

import SwiftUI

struct TabBarView: View {
    @ObservedObject var viewModel: TabBarViewModel

    var body: some View {
        HStack {
            Spacer(minLength: 0)
            Button {
                // Action for refresh
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(.primary)
            }
            Spacer(minLength: 0)
            Button {
                // Action for group/sequence
            } label: {
                Image(systemName: "person.3.sequence")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(.primary)
            }
            Spacer(minLength: 0)
            Button {
                viewModel.showCompose()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 2)
                    Image("quill")
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                }
                .frame(width: 60, height: 60)
            }
            .accessibilityLabel("Compose")
            Spacer(minLength: 0)
            Button {
                // Action for add person
            } label: {
                Image(systemName: "person.badge.plus")
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
    }
}
