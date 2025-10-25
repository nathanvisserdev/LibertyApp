//
//  CreatePostModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-25.
//

import Foundation

struct CreatePostRequest: Codable {
    let content: String
}

struct CreatePostResponse: Codable {
    let id: String
    let content: String
    let createdAt: String
    let userId: String
}

struct PostsAPI {
    static func createPost(content: String) async throws -> CreatePostResponse {
        // Build relative to the app's base URL
        let url = URL(string: "/posts", relativeTo: AppConfig.base)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.read() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Backend now expects only { content }
        let body = CreatePostRequest(content: content)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }

        if (200...299).contains(http.statusCode) {
            return try JSONDecoder().decode(CreatePostResponse.self, from: data)
        } else {
            let msg = (try? JSONDecoder().decode([String: String].self, from: data)["message"]) ?? "Unknown error"
            throw NSError(domain: "PostsAPI", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])
        }
    }
}
