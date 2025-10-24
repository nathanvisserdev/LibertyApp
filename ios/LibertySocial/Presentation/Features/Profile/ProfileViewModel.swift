//
//  ProfileViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isOwnProfile: Bool = false
    
    func loadProfile(userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            profile = try await AuthService.fetchUserProfile(userId: userId)
            
            // Check if this is the current user's profile
            isOwnProfile = await checkIfOwnProfile(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func checkIfOwnProfile(userId: String) async -> Bool {
        do {
            guard let token = KeychainHelper.read() else { return false }
            
            var req = URLRequest(url: AuthService.baseURL.appendingPathComponent("/user/me"))
            req.httpMethod = "GET"
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return false }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let currentUserId = json["id"] as? String {
                return currentUserId == userId
            }
        } catch {
            print("❌ Failed to check if own profile: \(error)")
        }
        
        return false
    }
}
