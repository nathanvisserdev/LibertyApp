//
//  CreatePostModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-25.
//

import Foundation
import UIKit

// MARK: - API Request/Response Types
struct PresignedUploadRequest: Codable {
    let contentType: String
}

struct PresignedUploadResponse: Codable {
    let url: String
    let method: String
    let headersOrFields: [String: String]
    let key: String
}

struct CreatePostRequest: Codable {
    let content: String?
    let media: String?
    let imageWidth: Double?
    let imageHeight: Double?
}

struct CreatePostResponse: Codable {
    let id: String
    let content: String?
    let media: String?
    let createdAt: String
    let userId: String
}

// MARK: - CreatePostModel
struct CreatePostModel {
    
    private let authSession: AuthSession
    private let subnetSession: SubnetSession
    
    init(authSession: AuthSession = AuthService.shared,
         subnetSession: SubnetSession = SubnetService.shared) {
        self.authSession = authSession
        self.subnetSession = subnetSession
    }
    
    // MARK: - Get Current User's isPrivate status
    func getCurrentUserIsPrivate() async throws -> Bool {
        return try await authSession.getCurrentUserIsPrivate()
    }
    
    // MARK: - Get Current User's Subnets
    func getUserSubnets() async throws -> [Subnet] {
        return try await subnetSession.getUserSubnets()
    }
    
    // MARK: - Request presigned upload URL from server
    func requestPresignedUpload(contentType: String = "image/jpeg") async throws -> PresignedUploadResponse {
        let url = URL(string: "/uploads/presign", relativeTo: AppConfig.baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let token = try authSession.getAuthToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body = PresignedUploadRequest(contentType: contentType)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }

        if (200...299).contains(http.statusCode) {
            return try JSONDecoder().decode(PresignedUploadResponse.self, from: data)
        } else {
            let msg = (try? JSONDecoder().decode([String: String].self, from: data)["message"]) ?? "Unknown error"
            throw NSError(domain: "CreatePostModel", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])
        }
    }
    
    // MARK: - Upload photo to R2 using presigned URL
    func uploadPhoto(data: Data, uploadData: PresignedUploadResponse) async throws {
        guard let url = URL(string: uploadData.url) else {
            throw NSError(domain: "CreatePostModel", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid upload URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = uploadData.method
        
        // Set headers from presigned response
        for (key, value) in uploadData.headersOrFields {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        request.httpBody = data
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "CreatePostModel", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to upload photo"])
        }
        
        print("📸 CreatePostModel: Successfully uploaded photo to R2")
    }
    
    // MARK: - Create post
    func createPost(content: String?, media: String? = nil, imageWidth: CGFloat? = nil, imageHeight: CGFloat? = nil) async throws -> CreatePostResponse {
        let url = URL(string: "/posts", relativeTo: AppConfig.baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let token = try authSession.getAuthToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body = CreatePostRequest(
            content: content,
            media: media,
            imageWidth: imageWidth != nil ? Double(imageWidth!) : nil,
            imageHeight: imageHeight != nil ? Double(imageHeight!) : nil
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }

        if (200...299).contains(http.statusCode) {
            return try JSONDecoder().decode(CreatePostResponse.self, from: data)
        } else {
            let msg = (try? JSONDecoder().decode([String: String].self, from: data)["message"]) ?? "Unknown error"
            throw NSError(domain: "CreatePostModel", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])
        }
    }
}
