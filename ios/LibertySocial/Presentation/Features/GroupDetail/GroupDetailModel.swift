//
//  GroupDetailModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-27.
//

import Foundation

// MARK: - Group Detail Response
struct GroupDetail: Codable {
    let id: String
    let name: String
    let description: String?
    let groupType: String
    let isHidden: Bool
    let membershipHidden: Bool
    let adminId: String
    let admin: GroupAdmin
    let createdAt: Date
    let displayLabel: String
    let memberCount: Int
    let members: [GroupMember]
    let memberVisibility: String
    let isMember: Bool
    let isAdmin: Bool
}

struct GroupMember: Codable, Identifiable {
    let membershipId: String
    let userId: String
    let joinedAt: Date
    let user: MemberUser
    
    var id: String { membershipId }
}

struct MemberUser: Codable {
    let id: String
    let username: String
    let firstName: String?
    let lastName: String?
}

// MARK: - API
struct GroupDetailModel {
    static func fetchGroupDetail(groupId: String) async throws -> GroupDetail {
        guard let url = URL(string: "\(AppConfig.baseURL)/groups/\(groupId)") else {
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
            let groupDetail = try decoder.decode(GroupDetail.self, from: data)
            return groupDetail
        } else {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data)["error"]) ?? "Failed to fetch group details"
            throw NSError(domain: "GroupDetailModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
    
    static func joinGroup(groupId: String) async throws {
        guard let url = URL(string: "\(AppConfig.baseURL)/groups/\(groupId)/join") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = KeychainHelper.read() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data)["error"]) ?? "Failed to join group"
            throw NSError(domain: "GroupDetailModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
}
