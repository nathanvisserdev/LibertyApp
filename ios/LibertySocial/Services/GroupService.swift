//
//  GroupService.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

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
    
    // MARK: - Dependencies
    private let authSession: AuthSession
    
    // MARK: - Cache Management
    private var cachedGroups: [UserGroup]?
    private var needsRefresh: Bool = true
    
    // MARK: - Change Signaling
    private let groupsDidChangeSubject = PassthroughSubject<Void, Never>()
    var groupsDidChange: AnyPublisher<Void, Never> {
        groupsDidChangeSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Init
    init(authSession: AuthSession = AuthService.shared) {
        self.authSession = authSession
    }
    
    // MARK: - Public API
    
    /// Invalidate the cache and signal subscribers that groups have changed
    func invalidateCache() {
        needsRefresh = true
        cachedGroups = nil
        groupsDidChangeSubject.send()
    }
    
    /// Fetch user groups with caching
    func getUserGroups(userId: String) async throws -> [UserGroup] {
        // Return cached data if available and fresh
        if !needsRefresh, let cachedGroups {
            return cachedGroups
        }
        
        // Fetch fresh data from server
        let groups = try await fetchFromServer(userId: userId)
        
        // Update cache
        cachedGroups = groups
        needsRefresh = false
        
        return groups
    }
    
    // MARK: - Private Helpers
    
    private func fetchFromServer(userId: String) async throws -> [UserGroup] {
        let token = try authSession.getAuthToken()
        
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
