//
//  MainModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-01-28.
//

import Foundation

struct MainModel {
    private let authSession: AuthSession
    
    init(authSession: AuthSession = AuthService.shared) {
        self.authSession = authSession
    }
    
    func fetchCurrentUser() async throws -> [String: Any] {
        let token = try authSession.getAuthToken()
        
        var request = URLRequest(url: AuthService.baseURL.appendingPathComponent("/me"))
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "MainModel", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch current user"])
        }
        
        guard let result = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "MainModel", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
        }
        
        return result
    }
}
