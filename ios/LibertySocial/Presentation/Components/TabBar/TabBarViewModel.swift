//
//  TabBarViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-10.
//

import Foundation
import Combine

@MainActor
final class TabBarViewModel: ObservableObject {
    // MARK: - Published Properties (State Only)
    @Published var currentUserPhotoKey: String?
    @Published var currentUserId: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Public Methods
    
    /// Fetch current user's photo and ID from /user/me
    func fetchCurrentUserInfo() async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let token = KeychainHelper.read() else {
                errorMessage = "No authentication token"
                isLoading = false
                return
            }
            
            var req = URLRequest(url: AuthService.baseURL.appendingPathComponent("/user/me"))
            req.httpMethod = "GET"
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                errorMessage = "Failed to fetch user info"
                isLoading = false
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let photoKey = json["profilePhoto"] as? String {
                    currentUserPhotoKey = photoKey
                }
                if let userId = json["id"] as? String {
                    currentUserId = userId
                }
            }
            
            isLoading = false
        } catch {
            errorMessage = "Failed to fetch current user info: \(error.localizedDescription)"
            isLoading = false
        }
    }
}
