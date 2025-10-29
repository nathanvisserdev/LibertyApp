//
//  CreateGroupModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-27.
//

import Foundation

// MARK: - Domain Model
enum GroupType: String, CaseIterable {
    case autocratic = "AUTOCRATIC"
    case roundTable = "ROUND_TABLE"
    
    var displayName: String {
        switch self {
        case .autocratic: return "Autocratic"
        case .roundTable: return "Round Table"
        }
    }
    
    var description: String {
        switch self {
        case .autocratic: return "Group admin has full control"
        case .roundTable: return "Decisions made democratically by members"
        }
    }
}

enum GroupPrivacy: String, CaseIterable {
    case publicGroup = "PUBLIC"
    case privateGroup = "PRIVATE"
    case personalGroup = "PERSONAL"
    
    var displayName: String {
        switch self {
        case .publicGroup: return "Public"
        case .privateGroup: return "Private"
        case .personalGroup: return "Personal"
        }
    }
    
    var description: String {
        switch self {
        case .publicGroup: return "Publicly visible to everyone"
        case .privateGroup: return "Only members can see content"
        case .personalGroup: return "Only acquaintances can join"
        }
    }
}

// MARK: - DTOs
struct CreateGroupRequest: Codable {
    let name: String
    let description: String?
    let groupType: String
    let groupPrivacy: String
    let isHidden: Bool
}

struct CreateGroupResponse: Codable {
    let id: String
    let name: String
    let groupType: String
    let groupPrivacy: String
    let isHidden: Bool
}

// MARK: - API
struct CreateGroupModel {
    static func createGroup(name: String, description: String?, groupType: String, groupPrivacy: String, isHidden: Bool) async throws -> CreateGroupResponse {
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
            groupPrivacy: groupPrivacy,
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
