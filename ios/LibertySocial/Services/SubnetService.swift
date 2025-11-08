
import Foundation
import Combine

struct Subnet: Codable, Identifiable {
    let id: String
    let name: String
    let slug: String
    let description: String?
    let visibility: String
    let isDefault: Bool
    let ordering: Int
    let memberCount: Int
    let postCount: Int
    let ownerId: String
    let parentId: String?
    let createdAt: Date
    let updatedAt: Date
    let owner: SubnetOwner
    let parent: SubnetParent?
    let children: [SubnetChild]
}

struct SubnetOwner: Codable {
    let id: String
    let username: String
    let firstName: String?
    let lastName: String?
}

struct SubnetParent: Codable {
    let id: String
    let name: String
    let slug: String
}

struct SubnetChild: Codable, Identifiable {
    let id: String
    let name: String
    let slug: String
}

protocol SubnetSession {
    func getUserSubnets() async throws -> [Subnet]
    var subnetsDidChange: AnyPublisher<Void, Never> { get }
    func invalidateCache()
}

@MainActor
final class SubnetService: SubnetSession {
    static let shared = SubnetService()
    
    private let TokenProvider: TokenProviding
    
    private var cachedSubnets: [Subnet]?
    private var needsRefresh: Bool = true
    private let subnetsDidChangeSubject = PassthroughSubject<Void, Never>()
    
    var subnetsDidChange: AnyPublisher<Void, Never> {
        subnetsDidChangeSubject.eraseToAnyPublisher()
    }
    
    init(TokenProvider: TokenProviding = AuthManager.shared) {
        self.TokenProvider = TokenProvider
    }
    
    
    func invalidateCache() {
        needsRefresh = true
        cachedSubnets = nil
        subnetsDidChangeSubject.send()
    }
    
    func shouldRefresh() -> Bool {
        return needsRefresh
    }
    
    func getUserSubnets() async throws -> [Subnet] {
        if !needsRefresh, let cached = cachedSubnets {
            return cached
        }
        
        guard let url = URL(string: "\(AppConfig.baseURL)/subnets") else {
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
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data)["error"]) ?? "Failed to fetch subnets"
            throw NSError(domain: "SubnetService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let subnets = try decoder.decode([Subnet].self, from: data)
        
        cachedSubnets = subnets
        needsRefresh = false
        
        return subnets
    }
}
