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
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
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
        _ = try await authService.signup(request)
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
