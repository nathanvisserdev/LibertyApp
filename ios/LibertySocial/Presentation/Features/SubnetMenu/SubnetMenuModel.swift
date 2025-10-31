//
//  SubnetMenuModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import Foundation

// MARK: - API
struct SubnetMenuModel {
    
    private let subnetSession: SubnetSession
    private let authSession: AuthSession
    
    init(subnetSession: SubnetSession = SubnetService.shared, authSession: AuthSession = AuthService.shared) {
        self.subnetSession = subnetSession
        self.authSession = authSession
    }
    
    func fetchSubnets() async throws -> [Subnet] {
        return try await subnetSession.getUserSubnets()
    }
    
    func deleteSubnet(subnetId: String) async throws {
        guard let url = URL(string: "\(AppConfig.baseURL)/subnets/\(subnetId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let token = try authSession.getAuthToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        // 204 is success for DELETE
        guard httpResponse.statusCode == 204 else {
            // Try to decode error message from response
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data))?["error"] ?? "Failed to delete subnet"
            throw NSError(domain: "SubnetMenuModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
    
    func updateSubnetOrdering(subnetId: String, ordering: Int) async throws {
        guard let url = URL(string: "\(AppConfig.baseURL)/subnets/\(subnetId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let token = try authSession.getAuthToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body = ["ordering": ordering]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data))?["error"] ?? "Failed to update subnet ordering"
            throw NSError(domain: "SubnetMenuModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
}
