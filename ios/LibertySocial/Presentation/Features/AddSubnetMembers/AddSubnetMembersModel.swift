//
//  AddSubnetMembersModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-30.
//

import Foundation

struct AddSubnetMembersModel {
    func fetchEligibleConnections(subnetId: String) async throws -> [Connection] {
        guard let url = URL(string: "\(AppConfig.baseURL)/me/subnets/\(subnetId)/eligible-connections") else {
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
            let connections = try decoder.decode([Connection].self, from: data)
            return connections
        } else {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data)["error"]) ?? "Failed to fetch eligible connections"
            throw NSError(domain: "AddSubnetMembersModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
}
