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
    @Published var items: [FeedItem] = []
    @Published var isLoading = false
    @Published var error: String?

    var mine:          [FeedItem] { items.filter { $0.relation == "SELF" } }
    var acquaintances: [FeedItem] { items.filter { $0.relation == "ACQUAINTANCE" } }
    var strangers:     [FeedItem] { items.filter { $0.relation == "STRANGER" } }
    var following:     [FeedItem] { items.filter { $0.relation == "FOLLOWING" } }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            items = try await AuthService.fetchFeed()
        } catch {
            self.error = String(describing: error) // fix: use self.error, avoid shadowing
        }
    }

    func refresh() async { await load() }
}

