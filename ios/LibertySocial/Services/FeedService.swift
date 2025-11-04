//
//  FeedService.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import Foundation
import Combine

// MARK: - Feed Session Protocol
/// Minimal interface for feed-related operations
protocol FeedSession {
    func getFeed() async throws -> [FeedItem]
    var feedDidChange: AnyPublisher<Void, Never> { get }
    func invalidateCache()
}

// MARK: - Feed Service
@MainActor
final class FeedService: FeedSession {
    static let shared = FeedService()
    
    private let TokenProvider: TokenProviding
    
    // MARK: - Cache & Change Signaling
    private var cachedFeed: [FeedItem]?
    private var needsRefresh: Bool = true
    private let feedDidChangeSubject = PassthroughSubject<Void, Never>()
    
    var feedDidChange: AnyPublisher<Void, Never> {
        feedDidChangeSubject.eraseToAnyPublisher()
    }
    
    init(TokenProvider: TokenProviding = AuthService.shared) {
        self.TokenProvider = TokenProvider
    }
    
    // MARK: - Public Methods
    
    /// Invalidate the cache and signal that data needs to be refreshed
    func invalidateCache() {
        needsRefresh = true
        cachedFeed = nil
        feedDidChangeSubject.send()
    }
    
    /// Check if cache needs refresh
    func shouldRefresh() -> Bool {
        return needsRefresh
    }
    
    // MARK: - FeedSession Protocol
    /// Get the user's feed (with caching)
    func getFeed() async throws -> [FeedItem] {
        // Return cached data if available and not stale
        if !needsRefresh, let cached = cachedFeed {
            return cached
        }
        
        // Fetch fresh data from server
        guard let url = URL(string: "\(AppConfig.baseURL)/feed") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let token = try TokenProvider.getAuthToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data))?["error"] ?? "Failed to fetch feed"
            throw NSError(domain: "FeedService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let feed = try decoder.decode([FeedItem].self, from: data)
        
        // Update cache and reset stale flag
        cachedFeed = feed
        needsRefresh = false
        
        return feed
    }
}
