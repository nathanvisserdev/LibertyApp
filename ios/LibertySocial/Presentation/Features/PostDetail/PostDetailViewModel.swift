//
//  PostDetailViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-11-03.
//

import Foundation
import Combine

@MainActor
final class PostDetailViewModel: ObservableObject {
    // MARK: - Properties
    let postId: String
    private let comments: CommentService
    private let reactions: ReactionService
    
    // MARK: - Published
    @Published var commentList: [CommentItem] = []
    @Published var reactionSummary: ReactionSummary?
    @Published var isLoading = false
    @Published var error: String?
    @Published var cursor: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(postId: String, comments: CommentService, reactions: ReactionService) {
        self.postId = postId
        self.comments = comments
        self.reactions = reactions
        
        // Subscribe to reaction summary updates
        reactions.summary(for: postId)
            .sink { [weak self] summary in
                self?.reactionSummary = summary
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Intents
    func loadMore() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let (newComments, newCursor) = try await comments.fetch(postId: postId, cursor: cursor)
            commentList.append(contentsOf: newComments)
            cursor = newCursor
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func addComment(_ content: String) async {
        guard !content.isEmpty else { return }
        
        do {
            let newComment = try await comments.create(postId: postId, content: content)
            commentList.insert(newComment, at: 0)
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func toggleReaction(type: ReactionType, emoji: String? = nil) async {
        do {
            try await reactions.toggle(postId: postId, type: type, emoji: emoji)
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
}
