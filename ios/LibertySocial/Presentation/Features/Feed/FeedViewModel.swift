//
//  FeedViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-09.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class FeedViewModel: ObservableObject {
    // MARK: - Dependencies
    private let model: FeedModel
    private let feedService: FeedSession
    private let makeMediaVM: (String) -> MediaViewModel
    private let auth: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published
    @Published var items: [FeedItem] = []
    @Published var isLoading = false
    @Published var error: String?
    
    // MARK: - Coordinator Callbacks
    var onLogout: (() -> Void)?
    var onOpenPost: ((String) -> Void)?
    
    // MARK: - Init
    init(model: FeedModel, 
         feedService: FeedSession, 
         makeMediaVM: @escaping (String) -> MediaViewModel,
         auth: AuthServiceProtocol) {
        self.model = model
        self.feedService = feedService
        self.makeMediaVM = makeMediaVM
        self.auth = auth
        
        // Subscribe to feed changes from the service
        feedService.feedDidChange
            .sink { [weak self] in
                Task {
                    await self?.refresh()
                }
            }
            .store(in: &cancellables)
    }

    var mine:          [FeedItem] { items.filter { $0.relation == "SELF" } }
    var acquaintances: [FeedItem] { items.filter { $0.relation == "ACQUAINTANCE" } }
    var strangers:     [FeedItem] { items.filter { $0.relation == "STRANGER" } }
    var following:     [FeedItem] { items.filter { $0.relation == "FOLLOWING" } }
    
    func isUsersPost(_ item: FeedItem) -> Bool {
        return item.relation == "SELF"
    }
    
    // MARK: - Media VM Factory
    func makeMediaViewModel(for mediaKey: String) -> MediaViewModel {
        return makeMediaVM(mediaKey)
    }
    
    // MARK: - Actions
    func logoutTapped() {
        onLogout?()
    }
    
    func open(postId: String) {
        onOpenPost?(postId)
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
}

