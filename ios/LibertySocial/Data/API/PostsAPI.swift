//
//  PostsAPI.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-12.
//

import Foundation

struct PostsAPI {
    static func createPost(content: String) async throws -> PostRequestResponseDTO {
        // Build relative to the app's base URL
        let url = URL(string: "/posts", relativeTo: AppConfig.base)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.read() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Backend now expects only { content }
        let body = CreatePostRequestDTO(content: content)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }

        if (200...299).contains(http.statusCode) {
            return try JSONDecoder().decode(PostRequestResponseDTO.self, from: data)
        } else {
            let msg = (try? JSONDecoder().decode([String: String].self, from: data)["message"]) ?? "Unknown error"
            throw NSError(domain: "PostsAPI", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])
        }
    }
}

