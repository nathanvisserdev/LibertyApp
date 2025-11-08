
import Foundation
import Combine

protocol FeedSession {
    func getFeed() async throws -> [FeedItem]
    var feedDidChange: AnyPublisher<Void, Never> { get }
    func invalidateCache()
}

@MainActor
final class FeedService: FeedSession {
    static let shared = FeedService()
    
    private let TokenProvider: TokenProviding
    
    private var cachedFeed: [FeedItem]?
    private var needsRefresh: Bool = true
    private let feedDidChangeSubject = PassthroughSubject<Void, Never>()
    
    var feedDidChange: AnyPublisher<Void, Never> {
        feedDidChangeSubject.eraseToAnyPublisher()
    }
    
    init(TokenProvider: TokenProviding = AuthManager.shared) {
        self.TokenProvider = TokenProvider
    }
    
    
    func invalidateCache() {
        needsRefresh = true
        cachedFeed = nil
        feedDidChangeSubject.send()
    }
    
    func shouldRefresh() -> Bool {
        return needsRefresh
    }
    
    func getFeed() async throws -> [FeedItem] {
        if !needsRefresh, let cached = cachedFeed {
            return cached
        }
        
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
        
        cachedFeed = feed
        needsRefresh = false
        
        return feed
    }
}
