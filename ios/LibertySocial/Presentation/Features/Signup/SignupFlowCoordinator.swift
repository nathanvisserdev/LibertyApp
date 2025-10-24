//
//  SignupFlowCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import SwiftUI
import Combine

enum SignupStep: Int, CaseIterable {
    case credentials = 0
    case name = 1
    case username = 2
    case demographics = 3
    case photo = 4
    case about = 5
    case phone = 6
    case complete = 7
}

@MainActor
final class SignupFlowCoordinator: ObservableObject {
    @Published var currentStep: SignupStep = .credentials
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var username: String = ""
    @Published var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    @Published var gender: String = "PREFER_NOT_TO_SAY"
    @Published var photo: String = ""
    @Published var about: String = ""
    @Published var phoneNumber: String = ""
    
    // Store photo data temporarily until after signup
    @Published var photoData: Data?
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showWelcome: Bool = false
    @Published var photoUploadSuccess: Bool = false
    @Published var photoUploadMessage: String?
    
    func nextStep() {
        if let next = SignupStep(rawValue: currentStep.rawValue + 1) {
            currentStep = next
        }
    }
    
    func skipToComplete() {
        currentStep = .complete
        showWelcome = true
    }
    
    func completeSignup() async {
        print("🚀 completeSignup: Starting signup process...")
        print("🚀 completeSignup: Has photo data? \(photoData != nil)")
        if let photoData = photoData {
            print("🚀 completeSignup: Photo data size: \(photoData.count) bytes")
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            let request = SignupRequest(
                firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                username: username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                password: password,
                dateOfBirth: formatter.string(from: dateOfBirth),
                gender: gender,
                phoneNumber: {
                    let trimmed = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
                    return trimmed.isEmpty ? nil : trimmed
                }(),
                profilePhoto: nil, // Will be uploaded after login
                about: {
                    let trimmed = about.trimmingCharacters(in: .whitespacesAndNewlines)
                    return trimmed.isEmpty ? nil : trimmed
                }()
            )
            
            print("📝 completeSignup: Calling signup endpoint...")
            try await AuthService.signup(request)
            print("✅ completeSignup: Signup successful!")
            
            // Auto-login after signup
            print("🔐 completeSignup: Auto-logging in...")
            _ = try await AuthService.login(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
            print("✅ completeSignup: Login successful!")
            
            // Upload photo if one was selected
            if let photoData = photoData {
                do {
                    print("📸 completeSignup: Starting photo upload with \(photoData.count) bytes...")
                    try await uploadPhoto(photoData: photoData)
                    photoUploadSuccess = true
                    photoUploadMessage = "Profile photo uploaded successfully! ✓"
                    print("✅ completeSignup: Photo upload completed successfully")
                } catch {
                    print("❌ completeSignup: Photo upload failed!")
                    print("❌ completeSignup: Error: \(error)")
                    print("❌ completeSignup: Error description: \(error.localizedDescription)")
                    
                    if let nsError = error as NSError? {
                        print("❌ completeSignup: Error domain: \(nsError.domain)")
                        print("❌ completeSignup: Error code: \(nsError.code)")
                        print("❌ completeSignup: Error userInfo: \(nsError.userInfo)")
                    }
                    
                    photoUploadSuccess = false
                    photoUploadMessage = "Photo upload failed, but your account was created. You can upload a photo later."
                    // Don't fail signup if photo upload fails
                }
            }
            
            // Successfully signed up - no error
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func uploadPhoto(photoData: Data) async throws {
        print("📸 uploadPhoto: Starting photo upload process...")
        print("📸 uploadPhoto: Photo data size: \(photoData.count) bytes")
        
        // Get presigned URL
        print("📸 uploadPhoto: Step 1 - Getting presigned URL...")
        let presignResponse = try await getPresignedURL(contentType: "image/jpeg")
        print("📸 uploadPhoto: Got presigned URL: \(presignResponse.url)")
        print("📸 uploadPhoto: Photo key: \(presignResponse.key)")
        
        // Upload to R2
        print("📸 uploadPhoto: Step 2 - Uploading to R2...")
        try await uploadToR2(imageData: photoData, presignResponse: presignResponse)
        print("📸 uploadPhoto: Successfully uploaded to R2")
        
        // Update user's photo URL
        print("📸 uploadPhoto: Step 3 - Updating user's photo in database...")
        let photoKey = try await updateUserPhoto(key: presignResponse.key)
        print("📸 uploadPhoto: Photo key saved: \(photoKey)")
        
        // Update coordinator with photo key
        photo = photoKey
        print("📸 uploadPhoto: Photo upload complete!")
    }
    
    private func getPresignedURL(contentType: String) async throws -> PresignResponse {
        guard let token = KeychainHelper.read() else {
            throw NSError(domain: "SignupFlowCoordinator", code: 401, userInfo: [NSLocalizedDescriptionKey: "No auth token"])
        }
        
        let body = ["contentType": contentType]
        let data = try JSONSerialization.data(withJSONObject: body)
        
        var req = URLRequest(url: AuthService.baseURL.appendingPathComponent("/uploads/presign"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.httpBody = data
        
        let (responseData, response) = try await URLSession.shared.data(for: req)
        
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw NSError(domain: "SignupFlowCoordinator", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to get presigned URL"])
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
            throw NSError(domain: "SignupFlowCoordinator", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to upload photo"])
        }
    }
    
    private func updateUserPhoto(key: String) async throws -> String {
        guard let token = KeychainHelper.read() else {
            throw NSError(domain: "SignupFlowCoordinator", code: 401, userInfo: [NSLocalizedDescriptionKey: "No auth token"])
        }
        
        let body = ["key": key]
        let data = try JSONSerialization.data(withJSONObject: body)
        
        var req = URLRequest(url: AuthService.baseURL.appendingPathComponent("/users/me/photo"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.httpBody = data
        
        let (responseData, response) = try await URLSession.shared.data(for: req)
        
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw NSError(domain: "SignupFlowCoordinator", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to update photo"])
        }
        
        let photoResponse = try JSONDecoder().decode(PhotoUpdateResponse.self, from: responseData)
        return photoResponse.profilePhoto
    }
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
