//
//  SubnetListModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-30.
//

import Foundation

// MARK: - Subnet Models
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

struct SubnetParent: Codable, Identifiable {
    let id: String
    let name: String
    let slug: String
}

struct SubnetChild: Codable, Identifiable {
    let id: String
    let name: String
    let slug: String
}

// MARK: - API
struct SubnetListModel {
    static func fetchSubnets() async throws -> [Subnet] {
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
            let subnets = try decoder.decode([Subnet].self, from: data)
            return subnets
        } else {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data)["error"]) ?? "Failed to fetch subnets"
            throw NSError(domain: "SubnetListModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
}
