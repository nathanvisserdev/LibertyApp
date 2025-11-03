//
//  PostDetailView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-11-03.
//

import SwiftUI

struct PostDetailView: View {
    @ObservedObject var viewModel: PostDetailViewModel
    @State private var commentText = ""
    
    init(viewModel: PostDetailViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading && viewModel.commentList.isEmpty {
                ProgressView("Loading comments...")
            } else {
                List {
                    // Reaction Summary Section
                    if let summary = viewModel.reactionSummary {
                        Section("Reactions") {
                            reactionSummaryView(summary)
                        }
                    }
                    
                    // Comments Section
                    Section("Comments") {
                        ForEach(viewModel.commentList) { comment in
                            CommentRowView(comment: comment)
                        }
                        
                        if viewModel.cursor != nil {
                            Button("Load More") {
                                Task { await viewModel.loadMore() }
                            }
                        }
                    }
                }
            }
            
            // Comment Input
            HStack {
                TextField("Add a comment...", text: $commentText)
                    .textFieldStyle(.roundedBorder)
                
                Button("Post") {
                    Task {
                        await viewModel.addComment(commentText)
                        commentText = ""
                    }
                }
                .disabled(commentText.isEmpty)
            }
            .padding()
        }
        .navigationTitle("Post Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadMore()
        }
    }
    
    @ViewBuilder
    private func reactionSummaryView(_ summary: ReactionSummary) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                reactionButton(type: .bell, count: summary.bellCount, emoji: "🔔")
                reactionButton(type: .trueReaction, count: summary.trueCount, emoji: "✅")
                reactionButton(type: .falseReaction, count: summary.falseCount, emoji: "❌")
            }
            
            if !summary.emojiReactions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(summary.emojiReactions, id: \.emoji) { emojiCount in
                            Button {
                                Task {
                                    await viewModel.toggleReaction(type: .emoji, emoji: emojiCount.emoji)
                                }
                            } label: {
                                Text("\(emojiCount.emoji) \(emojiCount.count)")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(16)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func reactionButton(type: ReactionType, count: Int, emoji: String) -> some View {
        Button {
            Task {
                await viewModel.toggleReaction(type: type)
            }
        } label: {
            HStack {
                Text(emoji)
                Text("\(count)")
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(16)
        }
    }
}

struct CommentRowView: View {
    let comment: CommentItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(comment.content)
                .font(.body)
            
            Text(formatDate(comment.createdAt))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: isoString) else { return isoString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .short
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}
