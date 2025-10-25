//
//  TabBarModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-25.
//

import Foundation

struct CurrentUserInfo {
    let photoKey: String?
    let userId: String?
}

struct TabBarModel {
    /// Fetch current user's photo and ID from /user/me
    static func fetchCurrentUserInfo() async throws -> CurrentUserInfo {
        guard let token = KeychainHelper.read() else {
            throw NSError(domain: "TabBarModel", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token"])
        }
        
        var req = URLRequest(url: AuthService.baseURL.appendingPathComponent("/user/me"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw NSError(domain: "TabBarModel", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch user info"])
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            let photoKey = json["profilePhoto"] as? String
            let userId = json["id"] as? String
            return CurrentUserInfo(photoKey: photoKey, userId: userId)
        }
        
        throw NSError(domain: "TabBarModel", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
    }
}
