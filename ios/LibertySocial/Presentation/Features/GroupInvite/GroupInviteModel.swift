//
//  GroupInviteModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import Foundation

// MARK: - Invitee Response Model
struct InviteeUser: Codable, Identifiable {
    let id: String
    let username: String
    let firstName: String?
    let lastName: String?
    let profilePhoto: String?
}

// MARK: - Model
struct GroupInviteModel {
    private let authSession: AuthSession
    
    init(authSession: AuthSession = AuthService.shared) {
        self.authSession = authSession
    }
    
    /// Fetch eligible users to invite to the group
    func fetchInvitees(groupId: String, include: String? = nil, exclude: String? = nil) async throws -> [InviteeUser] {
        var urlComponents = URLComponents(string: "\(AppConfig.baseURL)/groups/\(groupId)/invitees")!
        
        var queryItems: [URLQueryItem] = []
        if let include = include {
            queryItems.append(URLQueryItem(name: "include", value: include))
        }
        if let exclude = exclude {
            queryItems.append(URLQueryItem(name: "exclude", value: exclude))
        }
        if !queryItems.isEmpty {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let token = try authSession.getAuthToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            let decoder = JSONDecoder()
            return try decoder.decode([InviteeUser].self, from: data)
        } else {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data)["error"]) ?? "Failed to fetch invitees"
            throw NSError(domain: "GroupInviteModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
    
    /// Send group invites to selected users
    func sendInvites(groupId: String, userIds: [String]) async throws {
        guard let url = URL(string: "\(AppConfig.baseURL)/groups/\(groupId)/invite") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let token = try authSession.getAuthToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body = ["userIds": userIds]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data)["error"]) ?? "Failed to send invites"
            throw NSError(domain: "GroupInviteModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
}
