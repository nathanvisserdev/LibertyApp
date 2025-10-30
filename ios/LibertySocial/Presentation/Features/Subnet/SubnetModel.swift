//
//  SubnetModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-30.
//

import Foundation

// MARK: - Subnet Member Models
struct SubnetMember: Codable, Identifiable {
    let id: String
    let role: String
    let subnetId: String
    let userId: String
    let connectionId: String
    let createdAt: Date
    let user: SubnetMemberUser
}

struct SubnetMemberUser: Codable {
    let id: String
    let username: String
    let firstName: String?
    let lastName: String?
    let profilePhoto: String?
}

// MARK: - API
struct SubnetModel {
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    /// Fetch subnet members
    func fetchMembers(subnetId: String) async throws -> [SubnetMember] {
        guard let url = URL(string: "\(AppConfig.baseURL)/me/subnets/\(subnetId)/members") else {
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
            let members = try decoder.decode([SubnetMember].self, from: data)
            return members
        } else {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data)["error"]) ?? "Failed to fetch members"
            throw NSError(domain: "SubnetModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
}
