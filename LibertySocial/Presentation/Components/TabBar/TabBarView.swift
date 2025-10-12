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
            Spacer()
            Button {
                viewModel.showCompose()
            } label: {
                Image("quill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(18)
                    .background(
                        Circle()
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 2)
                    )
            }
            .accessibilityLabel("Compose")
            Spacer()
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


