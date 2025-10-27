//
//  CreateGroupModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-27.
//

import Foundation

// MARK: - Domain Model
enum GroupType: String, CaseIterable {
    case publicGroup = "PUBLIC"
    case privateGroup = "PRIVATE"
    
    var displayName: String {
        switch self {
        case .publicGroup: return "Public"
        case .privateGroup: return "Private"
        }
    }
    
    var description: String {
        switch self {
        case .publicGroup: return "Anyone can join and view content"
        case .privateGroup: return "Requires approval to join"
        }
    }
}

// MARK: - DTOs
struct CreateGroupRequest: Codable {
    let name: String
    let description: String?
    let groupType: String
    let isHidden: Bool
}

struct CreateGroupResponse: Codable {
    let id: String
    let name: String
    let groupType: String
    let isHidden: Bool
}

// MARK: - API
struct CreateGroupModel {
    static func createGroup(name: String, description: String?, groupType: String, isHidden: Bool) async throws -> CreateGroupResponse {
        guard let url = URL(string: "\(AppConfig.baseURL)/groups") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = KeychainHelper.read() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let body = CreateGroupRequest(
            name: name,
            description: description,
            groupType: groupType,
            isHidden: isHidden
        )
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        if (200...299).contains(httpResponse.statusCode) {
            return try JSONDecoder().decode(CreateGroupResponse.self, from: data)
        } else {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data)["error"]) ?? "Unknown error"
            throw NSError(domain: "CreateGroupModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
}
