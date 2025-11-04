//
//  SignupModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-25.
//

import Foundation

struct AvailabilityRequest: Encodable {
    let email: String?
    let username: String?
}

struct AvailabilityResponse: Decodable {
    let available: Bool
}

struct SignupModel {
    private let TokenProvider: TokenProviding
    private let AuthManager: AuthManaging
    
    init(TokenProvider: TokenProviding = AuthService.shared, AuthManager: AuthManaging = AuthService.shared) {
        self.TokenProvider = TokenProvider
        self.AuthManager = AuthManager
    }
    
    /// Check if email or username is available
    func checkAvailability(email: String? = nil, username: String? = nil) async throws -> Bool {
        let url = AuthService.baseURL.appendingPathComponent("/availability")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let availabilityReq = AvailabilityRequest(email: email, username: username)
        req.httpBody = try JSONEncoder().encode(availabilityReq)
        
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw NSError(domain: "SignupModel", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        if http.statusCode == 200 {
            let decoded = try JSONDecoder().decode(AvailabilityResponse.self, from: data)
            return decoded.available
        } else {
            throw NSError(domain: "SignupModel", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to check availability"])
        }
    }
    
    /// Signup user - AuthService handles token storage
    func signup(_ request: SignupRequest) async throws {
        _ = try await AuthManager.signup(request)
    }
    
    /// Upload profile photo - must be called after signup (requires auth token)
    func uploadPhoto(photoData: Data) async throws -> String {
        // Get presigned URL
        let presignResponse = try await getPresignedURL(contentType: "image/jpeg")
        
        // Upload to R2
        try await uploadToR2(imageData: photoData, presignResponse: presignResponse)
        
        // Update user's photo URL in database
        let photoKey = try await updateUserPhoto(key: presignResponse.key)
        
        return photoKey
    }
    
    // MARK: - Private Photo Upload Methods
    
    private func getPresignedURL(contentType: String) async throws -> PresignResponse {
        let token = try TokenProvider.getAuthToken()
        
        let body = ["contentType": contentType]
        let data = try JSONSerialization.data(withJSONObject: body)
        
        var req = URLRequest(url: AuthService.baseURL.appendingPathComponent("/uploads/presign"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.httpBody = data
        
        let (responseData, response) = try await URLSession.shared.data(for: req)
        
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw NSError(domain: "SignupModel", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to get presigned URL"])
        }
        
        return try JSONDecoder().decode(PresignResponse.self, from: responseData)
    }
    
    private func uploadToR2(imageData: Data, presignResponse: PresignResponse) async throws {
        var req = URLRequest(url: URL(string: presignResponse.url)!)
        req.httpMethod = "PUT"
        req.setValue(presignResponse.headersOrFields["Content-Type"], forHTTPHeaderField: "Content-Type")
        req.httpBody = imageData
        
        let (_, response) = try await URLSession.shared.data(for: req)
        
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw NSError(domain: "SignupModel", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to upload photo"])
        }
    }
    
    private func updateUserPhoto(key: String) async throws -> String {
        let token = try TokenProvider.getAuthToken()
        
        let body = ["key": key]
        let data = try JSONSerialization.data(withJSONObject: body)
        
        var req = URLRequest(url: AuthService.baseURL.appendingPathComponent("/users/me/photo"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.httpBody = data
        
        let (responseData, response) = try await URLSession.shared.data(for: req)
        
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw NSError(domain: "SignupModel", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to update photo"])
        }
        
        let photoResponse = try JSONDecoder().decode(PhotoUpdateResponse.self, from: responseData)
        return photoResponse.profilePhoto
    }
}

struct SignupRequest: Encodable {
    let firstName: String
    let lastName: String
    let email: String
    let username: String
    let password: String
    let dateOfBirth: String
    let gender: String
    let isPrivate: Bool
    let phoneNumber: String?
    let profilePhoto: String?
    let about: String?
    
    init(firstName: String, lastName: String, email: String, username: String, password: String, dateOfBirth: String, gender: String, isPrivate: Bool, phoneNumber: String? = nil, profilePhoto: String? = nil, about: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.username = username
        self.password = password
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.isPrivate = isPrivate
        self.phoneNumber = phoneNumber
        self.profilePhoto = profilePhoto
        self.about = about
    }
}

struct SignupResponse: Decodable { 
    let id: String
    let email: String
    let accessToken: String
}

struct PresignResponse: Decodable {
    let url: String
    let method: String
    let headersOrFields: [String: String]
    let key: String
}

struct PhotoUpdateResponse: Decodable {
    let profilePhoto: String
}
