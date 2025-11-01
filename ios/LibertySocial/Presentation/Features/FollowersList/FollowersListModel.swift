//
//  FollowersListModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import Foundation

struct FollowerUser: Codable, Identifiable {
    let id: String
    let username: String
    let firstName: String
    let lastName: String
    let profilePhoto: String?
}

struct FollowersListModel {
    private let authSession: AuthSession
    
    init(authSession: AuthSession = AuthService.shared) {
        self.authSession = authSession
    }
    
    /// Fetch the list of followers for a specific user
    func fetchFollowers(userId: String) async throws -> [FollowerUser] {
        let token = try authSession.getAuthToken()
        
        guard let url = URL(string: "\(AppConfig.baseURL)/users/\(userId)/followers") else {
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
            return try decoder.decode([FollowerUser].self, from: data)
        } else if httpResponse.statusCode == 403 {
            throw NSError(domain: "FollowersListModel", code: 403, userInfo: [NSLocalizedDescriptionKey: "This user's followers list is private"])
        } else {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data))?["error"] ?? "Failed to fetch followers"
            throw NSError(domain: "FollowersListModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
}
