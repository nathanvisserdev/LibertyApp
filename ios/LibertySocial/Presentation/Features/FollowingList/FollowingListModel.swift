//
//  FollowingListModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import Foundation

struct FollowingUser: Codable, Identifiable {
    let id: String
    let username: String
    let firstName: String
    let lastName: String
    let profilePhoto: String?
}

struct FollowingListModel {
    private let authSession: AuthSession
    
    init(authSession: AuthSession = AuthService.shared) {
        self.authSession = authSession
    }
    
    /// Fetch the list of users that a specific user is following
    func fetchFollowing(userId: String) async throws -> [FollowingUser] {
        let token = try authSession.getAuthToken()
        
        guard let url = URL(string: "\(AppConfig.baseURL)/users/\(userId)/following") else {
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
            return try decoder.decode([FollowingUser].self, from: data)
        } else if httpResponse.statusCode == 403 {
            throw NSError(domain: "FollowingListModel", code: 403, userInfo: [NSLocalizedDescriptionKey: "This user's following list is private"])
        } else {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data))?["error"] ?? "Failed to fetch following"
            throw NSError(domain: "FollowingListModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
}
