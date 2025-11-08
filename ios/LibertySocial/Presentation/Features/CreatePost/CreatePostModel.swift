
import Foundation
import UIKit

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
    let visibility: String?
    let subnetId: String?
}

struct CreatePostResponse: Codable {
    let postId: String
    let content: String?
    let media: String?
    let createdAt: String
    let userId: String
}

struct CreatePostModel {
    
    private let TokenProvider: TokenProviding
    private let subnetSession: SubnetSession
    
    init(TokenProvider: TokenProviding = AuthManager.shared,
         subnetSession: SubnetSession = SubnetService.shared) {
        self.TokenProvider = TokenProvider
        self.subnetSession = subnetSession
    }
    
    func getCurrentUserIsPrivate() async throws -> Bool {
        return try await TokenProvider.getCurrentUserIsPrivate()
    }
    
    func getUserSubnets() async throws -> [Subnet] {
        return try await subnetSession.getUserSubnets()
    }
    
    func requestPresignedUpload(contentType: String = "image/jpeg") async throws -> PresignedUploadResponse {
        let url = URL(string: "/uploads/presign", relativeTo: AppConfig.baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let token = try TokenProvider.getAuthToken()
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
    
    func uploadPhoto(data: Data, uploadData: PresignedUploadResponse) async throws {
        guard let url = URL(string: uploadData.url) else {
            throw NSError(domain: "CreatePostModel", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid upload URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = uploadData.method
        
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
    
    func createPost(content: String?, media: String? = nil, imageWidth: CGFloat? = nil, imageHeight: CGFloat? = nil, visibility: String, subnetId: String? = nil) async throws -> CreatePostResponse {
        let url = URL(string: "/posts", relativeTo: AppConfig.baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let token = try TokenProvider.getAuthToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body = CreatePostRequest(
            content: content,
            media: media,
            imageWidth: imageWidth != nil ? Double(imageWidth!) : nil,
            imageHeight: imageHeight != nil ? Double(imageHeight!) : nil,
            visibility: visibility,
            subnetId: subnetId
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
