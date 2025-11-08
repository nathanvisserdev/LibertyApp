
import Foundation
import Combine

protocol GroupSession {
    func getUserGroups(userId: String) async throws -> [UserGroup]
    var groupsDidChange: AnyPublisher<Void, Never> { get }
    func invalidateCache()
}

@MainActor
final class GroupService: GroupSession {
    
    static let shared = GroupService()
    
    private let TokenProvider: TokenProviding
    
    private var cachedGroups: [UserGroup]?
    private var needsRefresh: Bool = true
    
    private let groupsDidChangeSubject = PassthroughSubject<Void, Never>()
    var groupsDidChange: AnyPublisher<Void, Never> {
        groupsDidChangeSubject.eraseToAnyPublisher()
    }
    
    init(TokenProvider: TokenProviding = AuthManager.shared) {
        self.TokenProvider = TokenProvider
    }
    
    
    func invalidateCache() {
        needsRefresh = true
        cachedGroups = nil
        groupsDidChangeSubject.send()
    }
    
    func getUserGroups(userId: String) async throws -> [UserGroup] {
        if !needsRefresh, let cachedGroups {
            return cachedGroups
        }
        
        let groups = try await fetchFromServer(userId: userId)
        
        cachedGroups = groups
        needsRefresh = false
        
        return groups
    }
    
    
    private func fetchFromServer(userId: String) async throws -> [UserGroup] {
        let token = try TokenProvider.getAuthToken()
        
        guard let url = URL(string: "\(AppConfig.baseURL)/users/\(userId)/groups") else {
            throw NSError(domain: "GroupService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "GroupService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        if httpResponse.statusCode == 200 {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let responseData = try decoder.decode(UserGroupsResponse.self, from: data)
            return responseData.groups
        } else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "GroupService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
}
