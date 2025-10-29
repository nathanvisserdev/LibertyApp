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
    
    var iconName: String {
        switch self {
        case .publicGroup: return "lock.open"
        case .privateGroup: return "lock"
        case .personalGroup: return "lock.heart"
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

struct CreateRoundTableGroupRequest {
    let name: String
    let description: String?
    let groupPrivacy: String
    let requiresApproval: Bool
    let viceChairId: String
    let admins: [[String: Any]]
    let electionCycle: String?
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
    
    static func createRoundTableGroup(request: CreateRoundTableGroupRequest) async throws -> CreateGroupResponse {
        guard let url = URL(string: "\(AppConfig.baseURL)/groups") else {
            throw URLError(.badURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = KeychainHelper.read() else {
            throw NSError(domain: "CreateGroupModel", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        var body: [String: Any] = [
            "name": request.name,
            "groupType": "ROUND_TABLE",
            "groupPrivacy": request.groupPrivacy,
            "requiresApproval": request.requiresApproval,
            "viceChairId": request.viceChairId,
            "admins": request.admins
        ]
        
        if let description = request.description, !description.isEmpty {
            body["description"] = description
        }
        
        if let electionCycle = request.electionCycle {
            body["electionCycle"] = electionCycle
        }
        
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            return try JSONDecoder().decode(CreateGroupResponse.self, from: data)
        } else {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data))?["error"] ?? "Unknown error"
            throw NSError(domain: "CreateGroupModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
}
