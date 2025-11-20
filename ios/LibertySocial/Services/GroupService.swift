
import Foundation
import Combine

protocol GroupSession {
    func getUserGroups(userId: String) async throws -> [UserGroup]
    func fetchGroupDetail(groupId: String) async throws -> GroupDetail
    func joinGroup(groupId: String) async throws
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
    
    func fetchGroupDetail(groupId: String) async throws -> GroupDetail {
        let token = try TokenProvider.getAuthToken()
        
        guard let url = URL(string: "\(AppConfig.baseURL)/groups/\(groupId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let groupDetail = try decoder.decode(GroupDetail.self, from: data)
            return groupDetail
        } else {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data)["error"]) ?? "Failed to fetch group details"
            throw NSError(domain: "GroupService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
    
    func joinGroup(groupId: String) async throws {
        let token = try TokenProvider.getAuthToken()
        
        guard let url = URL(string: "\(AppConfig.baseURL)/groups/\(groupId)/join") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data)["error"]) ?? "Failed to join group"
            throw NSError(domain: "GroupService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
        
        invalidateCache()
    }
}
