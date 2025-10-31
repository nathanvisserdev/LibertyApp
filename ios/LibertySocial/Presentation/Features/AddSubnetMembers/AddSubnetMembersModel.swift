//
//  AddSubnetMembersModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-30.
//

import Foundation

struct AddSubnetMembersModel {
    
    private let authSession: AuthSession
    
    init(authSession: AuthSession = AuthService.shared) {
        self.authSession = authSession
    }
    
    func fetchEligibleConnections(subnetId: String) async throws -> [Connection] {
        guard let url = URL(string: "\(AppConfig.baseURL)/me/subnets/\(subnetId)/eligible-connections") else {
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
            let connections = try decoder.decode([Connection].self, from: data)
            return connections
        } else {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data)["error"]) ?? "Failed to fetch eligible connections"
            throw NSError(domain: "AddSubnetMembersModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
    
    func addMembers(subnetId: String, userIds: [String]) async throws {
        guard let url = URL(string: "\(AppConfig.baseURL)/subnets/\(subnetId)/members") else {
            throw URLError(.badURL)
        }
        
        print("Adding members to subnet: \(subnetId)")
        print("User IDs: \(userIds)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let token = try authSession.getAuthToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = ["userIds": userIds]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            throw NSError(domain: "AddSubnetMembersModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode request body"])
        }
        
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Request body: \(jsonString)")
        }
        
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            // Try to decode error message from server
            if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
               let errorMsg = errorResponse["error"] {
                throw NSError(domain: "AddSubnetMembersModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
            } else {
                throw NSError(domain: "AddSubnetMembersModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to add members"])
            }
        }
    }
}
