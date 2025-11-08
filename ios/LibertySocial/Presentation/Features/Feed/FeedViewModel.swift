
import Foundation
import Combine
import SwiftUI

struct CommentThreadState {
    var isOpen: Bool = false
    var isLoading: Bool = false
    var comments: [CommentItem] = []
    var inputText: String = ""
}

@MainActor
final class FeedViewModel: ObservableObject {
    private let model: FeedModel
    private let feedService: FeedSession
    private let makeMediaVM: (String) -> MediaViewModel
    private let auth: AuthManaging
    private let commentService: CommentService
    private let onShowProfile: (String) -> Void
    private var cancellables = Set<AnyCancellable>()

    @Published var items: [FeedItem] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var threads: [String: CommentThreadState] = [:]   // postId → comment thread

    init(model: FeedModel,
         feedService: FeedSession,
         makeMediaVM: @escaping (String) -> MediaViewModel,
         auth: AuthManaging,
         commentService: CommentService,
         onShowProfile: @escaping (String) -> Void) {
        self.model = model
        self.feedService = feedService
        self.makeMediaVM = makeMediaVM
        self.auth = auth
        self.commentService = commentService
        self.onShowProfile = onShowProfile

        feedService.feedDidChange
            .sink { [weak self] in
                Task { await self?.refresh() }
            }
            .store(in: &cancellables)
    }

    var mine:          [FeedItem] { items.filter { $0.relation == "SELF" } }
    var acquaintances: [FeedItem] { items.filter { $0.relation == "ACQUAINTANCE" } }
    var strangers:     [FeedItem] { items.filter { $0.relation == "STRANGER" } }
    var following:     [FeedItem] { items.filter { $0.relation == "FOLLOWING" } }

    func isUsersPost(_ item: FeedItem) -> Bool { item.relation == "SELF" }

    func makeMediaViewModel(for mediaKey: String) -> MediaViewModel {
        makeMediaVM(mediaKey)
    }

    func logoutTapped() {
        print("🔵 FeedViewModel.logoutTapped() - calling AuthManagerBadName.logout()")
        auth.logout()
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            items = try await model.fetchFeed()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func refresh() async {
        do {
            items = try await model.fetchFeed()
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }

    func toggleComments(for postId: String) {
        print("🔵 toggleComments called for postId: \(postId)")
        if threads[postId] == nil { threads[postId] = CommentThreadState() }
        threads[postId]!.isOpen.toggle()
        print("🔵 isOpen: \(threads[postId]!.isOpen), comments.isEmpty: \(threads[postId]!.comments.isEmpty)")
        if threads[postId]!.isOpen && threads[postId]!.comments.isEmpty {
            print("🔵 Triggering loadComments for postId: \(postId)")
            Task { await loadComments(for: postId) }
        }
    }

    func loadComments(for postId: String) async {
        print("🔵 loadComments started for postId: \(postId)")
        threads[postId]?.isLoading = true
        do {
            let (comments, nextCursor) = try await commentService.fetch(postId: postId, cursor: nil)
            print("🔵 Received \(comments.count) comments, nextCursor: \(nextCursor ?? "nil")")
            print("🔵 Comments: \(comments)")
            threads[postId]?.comments = comments
            print("🔵 Assigned comments to thread, current count: \(threads[postId]?.comments.count ?? 0)")
        } catch {
            print("🔴 Failed to load comments for \(postId): \(error)")
        }
        threads[postId]?.isLoading = false
        print("🔵 loadComments finished for postId: \(postId)")
    }
    
    func bindThread(for postId: String) -> Binding<CommentThreadState> {
        Binding(
            get: { self.threads[postId] ?? CommentThreadState() },
            set: { self.threads[postId] = $0 }
        )
    }
    
    func updateInput(for postId: String, to value: String) {
        if threads[postId] == nil { threads[postId] = CommentThreadState() }
        threads[postId]?.inputText = value
    }
    
    func submitComment(for postId: String) async {
        guard let thread = threads[postId], !thread.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let content = thread.inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        threads[postId]?.inputText = ""
        
        do {
            let newComment = try await commentService.create(postId: postId, content: content)
            threads[postId]?.comments.insert(newComment, at: 0)
        } catch {
            print("Failed to submit comment: \(error)")
        }
    }
    
    func showProfile(userId: String) {
        onShowProfile(userId)
    }
}
