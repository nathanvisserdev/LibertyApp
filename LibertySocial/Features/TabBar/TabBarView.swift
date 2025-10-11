//
//  TabView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-10.
//

// TabBarView.swift
import SwiftUI

struct TabBarView: View {
    @ObservedObject var viewModel: TabBarViewModel

    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                viewModel.showCompose()
            }) {
                Image("quill") // in Assets.xcassets
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
        .sheet(isPresented: $viewModel.isComposePresented) {
            ComposeView(viewModel: viewModel)
        }
    }
}

struct ComposeView: View {
    @ObservedObject var viewModel: TabBarViewModel

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                TextEditor(text: Binding(
                    get: { viewModel.postContent },
                    set: { viewModel.updatePostContent($0) }
                ))
                .frame(minHeight: 150)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                .accessibilityLabel("Compose Post")

                HStack {
                    Spacer()
                    Text("\(viewModel.remainingCharacters) characters left")
                        .foregroundColor(viewModel.remainingCharacters < 0 ? .red : .secondary)
                        .font(.caption)
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Compose Post")
            .navigationBarItems(leading: Button("Cancel") {
                viewModel.hideCompose()
            }, trailing: Button("Post") {
                // Add post logic here
                viewModel.hideCompose()
            }.disabled(viewModel.postContent.isEmpty || viewModel.remainingCharacters < 0))
        }
    }
}
