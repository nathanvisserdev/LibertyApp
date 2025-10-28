//
//  FeedViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-09.
//

import Foundation
import Combine

@MainActor
final class FeedViewModel: ObservableObject {
    // MARK: - Dependencies
    private let model: FeedModel
    
    // MARK: - Published
    @Published var items: [FeedItem] = []
    @Published var isLoading = false
    @Published var error: String?
    
    // MARK: - Init
    init(model: FeedModel = FeedModel()) {
        self.model = model
    }

    var mine:          [FeedItem] { items.filter { $0.relation == "SELF" } }
    var acquaintances: [FeedItem] { items.filter { $0.relation == "ACQUAINTANCE" } }
    var strangers:     [FeedItem] { items.filter { $0.relation == "STRANGER" } }
    var following:     [FeedItem] { items.filter { $0.relation == "FOLLOWING" } }
    
    func isUsersPost(_ item: FeedItem) -> Bool {
        return item.relation == "SELF"
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

