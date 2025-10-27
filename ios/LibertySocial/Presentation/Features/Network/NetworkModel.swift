//
//  NetworkModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-26.
//

import Foundation

// MARK: - User Group Response
struct UserGroupsResponse: Codable {
    let groups: [UserGroup]
}

struct UserGroup: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let groupType: String
    let isHidden: Bool
    let adminId: String
    let admin: GroupAdmin
    let displayLabel: String
    let joinedAt: Date
}

struct GroupAdmin: Codable {
    let id: String
    let username: String
    let firstName: String?
    let lastName: String?
}

// MARK: - API
struct NetworkModel {
    static func fetchUserGroups(userId: String) async throws -> [UserGroup] {
        guard let url = URL(string: "\(AppConfig.baseURL)/users/\(userId)/groups") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = KeychainHelper.read() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
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
            throw NSError(domain: "NetworkModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
}
