//
//  SuggestedGroupsModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-27.
//

import Foundation

// MARK: - Model
struct SuggestedGroupsModel {
    private let authSession: AuthSession
    private let authService: AuthServiceProtocol
    
    init(authSession: AuthSession = AuthService.shared, authService: AuthServiceProtocol = AuthService.shared) {
        self.authSession = authSession
        self.authService = authService
    }
    
    /// Fetch current user's ID
    func fetchCurrentUserId() async throws -> String {
        let currentUser = try await authService.fetchCurrentUserTyped()
        return currentUser.id
    }
    
    /// Fetch joinable groups for a user
    func fetchJoinableGroups(userId: String) async throws -> [UserGroup] {
        guard let url = URL(string: "\(AppConfig.baseURL)/users/\(userId)/groups") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let token = try authSession.getAuthToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let responseData = try decoder.decode(UserGroupsResponse.self, from: data)
            return responseData.groups
        } else {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data)["error"]) ?? "Failed to fetch groups"
            throw NSError(domain: "SuggestedGroupsModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
}

