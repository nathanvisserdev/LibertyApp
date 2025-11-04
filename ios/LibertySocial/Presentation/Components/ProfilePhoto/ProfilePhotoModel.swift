//
//  ProfilePhotoModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-25.
//


import Foundation

struct ProfilePhotoModel {
    private let TokenProvider: TokenProviding
    
    init(TokenProvider: TokenProviding = AuthService.shared) {
        self.TokenProvider = TokenProvider
    }
    
    func fetchPresignedURL(for photoKey: String) async throws -> (url: URL, expiresAt: Date) {
        let token = try TokenProvider.getAuthToken()
        
        let body = ["key": photoKey]
        let data = try JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: AuthService.baseURL.appendingPathComponent("/media/presign-read"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = data
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw NSError(domain: "ProfilePhotoModel", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to get presigned URL"])
        }
        
        let presignResponse = try JSONDecoder().decode(PresignReadResponse.self, from: responseData)
        
        print("📸 ProfilePhotoModel: Got presigned URL, expires at: \(Date(timeIntervalSince1970: Double(presignResponse.expiresAt) / 1000))")
        
        guard let url = URL(string: presignResponse.url) else {
            throw NSError(domain: "ProfilePhotoModel", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid URL in response"])
        }
        
        let expiresAt = Date(timeIntervalSince1970: Double(presignResponse.expiresAt) / 1000)
        
        return (url: url, expiresAt: expiresAt)
    }
}
