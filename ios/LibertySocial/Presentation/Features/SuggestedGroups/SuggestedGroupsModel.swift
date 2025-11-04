//
//  SuggestedGroupsModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-27.
//

import Foundation

// MARK: - Model
struct SuggestedGroupsModel {
    private let TokenProvider: TokenProviding
    private let AuthManager: AuthManaging
    
    init(TokenProvider: TokenProviding = AuthService.shared, AuthManager: AuthManaging = AuthService.shared) {
        self.TokenProvider = TokenProvider
        self.AuthManager = AuthManager
    }
    
    /// Fetch current user's ID
    func fetchCurrentUserId() async throws -> String {
        let currentUser = try await AuthManager.fetchCurrentUserTyped()
        return currentUser.id
    }
    
    /// Fetch joinable groups for a user
    func fetchJoinableGroups(userId: String) async throws -> [UserGroup] {
        guard let url = URL(string: "\(AppConfig.baseURL)/users/\(userId)/groups") else {
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

