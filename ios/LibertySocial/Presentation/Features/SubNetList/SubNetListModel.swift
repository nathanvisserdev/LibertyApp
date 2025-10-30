//
//  SubNetListModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-29.
//

import Foundation

// MARK: - SubNet Models
struct SubNet: Codable, Identifiable {
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
    let owner: SubNetOwner
    let parent: SubNetParent?
    let children: [SubNetChild]
}

struct SubNetOwner: Codable {
    let id: String
    let username: String
    let firstName: String?
    let lastName: String?
}

struct SubNetParent: Codable {
    let id: String
    let name: String
    let slug: String
}

struct SubNetChild: Codable {
    let id: String
    let name: String
    let slug: String
}

// MARK: - API
struct SubNetListModel {
    static func fetchSubNets() async throws -> [SubNet] {
        guard let url = URL(string: "\(AppConfig.baseURL)/subnets") else {
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
            let subnets = try decoder.decode([SubNet].self, from: data)
            return subnets
        } else {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data)["error"]) ?? "Failed to fetch subnets"
            throw NSError(domain: "SubNetListModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
}
