//
//  FeedCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-01-28.
//

import SwiftUI
import Combine

@MainActor
final class FeedCoordinator: ObservableObject {
    // MARK: - Dependencies
    private let authSession: AuthSession
    private let authService: AuthServiceProtocol
    private let feedService: FeedSession
    private let commentService: CommentService
    private let reactionService: ReactionService
    
    // MARK: - State
    @Published var navigationPath = NavigationPath()
    
    init(authSession: AuthSession = AuthService.shared,
         authService: AuthServiceProtocol = AuthService.shared,
         feedService: FeedSession = FeedService.shared,
         commentService: CommentService? = nil,
         reactionService: ReactionService? = nil) {
        self.authSession = authSession
        self.authService = authService
        self.feedService = feedService
        // TODO: Replace with actual implementations when available
        self.commentService = commentService ?? MockCommentService()
        self.reactionService = reactionService ?? MockReactionService()
    }
    
    func start() -> some View {
        FeedCoordinatorView(coordinator: self)
    }
    
    // MARK: - Factory Methods
    func makeFeedView() -> some View {
        let model = FeedModel(authService: authService)
        let viewModel = FeedViewModel(
            model: model,
            feedService: feedService,
            makeMediaVM: { mediaKey in
                MediaViewModel(mediaKey: mediaKey)
            },
            auth: authService
        )
        
        // Set up coordinator callbacks
        viewModel.onLogout = { [weak self] in
            self?.handleLogout()
        }
        
        viewModel.onOpenPost = { [weak self] postId in
            self?.openPostDetail(postId: postId)
        }
        
        return FeedView(viewModel: viewModel)
    }
    
    func makePostDetailView(postId: String) -> some View {
        let viewModel = PostDetailViewModel(
            postId: postId,
            comments: commentService,
            reactions: reactionService
        )
        return PostDetailView(viewModel: viewModel)
    }
    
    // MARK: - Navigation Actions
    private func handleLogout() {
        authService.deleteToken()
        // Navigation reset will be handled by SessionStore in LibertySocialApp
        NotificationCenter.default.post(name: NSNotification.Name("UserDidLogout"), object: nil)
    }
    
    private func openPostDetail(postId: String) {
        navigationPath.append(postId)
    }
}

// MARK: - Coordinator View
private struct FeedCoordinatorView: View {
    @ObservedObject var coordinator: FeedCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            coordinator.makeFeedView()
                .navigationDestination(for: String.self) { postId in
                    coordinator.makePostDetailView(postId: postId)
                }
        }
    }
}

// MARK: - Mock Services (temporary)
private class MockCommentService: CommentService {
    func fetch(postId: String, cursor: String?) async throws -> ([CommentItem], String?) {
        return ([], nil)
    }
    
    func create(postId: String, content: String) async throws -> CommentItem {
        return CommentItem(
            commentId: UUID().uuidString,
            content: content,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            userId: "",
            postId: postId,
            parentId: nil
        )
    }
    
    func delete(commentId: String) async throws {
        // Mock implementation
    }
}

private class MockReactionService: ReactionService {
    private let subject = CurrentValueSubject<ReactionSummary, Never>(
        ReactionSummary(
            postId: "",
            bellCount: 0,
            trueCount: 0,
            falseCount: 0,
            emojiReactions: [],
            userReactions: []
        )
    )
    
    func summary(for postId: String) -> AnyPublisher<ReactionSummary, Never> {
        return subject.eraseToAnyPublisher()
    }
    
    func toggle(postId: String, type: ReactionType, emoji: String?) async throws {
        // Mock implementation
    }
}
