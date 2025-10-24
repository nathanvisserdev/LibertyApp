//
//  TabBarViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-10.
//

import Foundation
import Combine

final class TabBarViewModel: ObservableObject {
    @Published var isShowingCompose: Bool = false
    @Published var isShowingSearch: Bool = false
    @Published var isShowingConnectionRequests: Bool = false
    @Published var isShowingNotifications: Bool = false
    @Published var isShowingProfile: Bool = false
    @Published var currentUserPhotoKey: String?
    @Published var currentUserId: String?

    func showCompose() { isShowingCompose = true }
    func hideCompose() { isShowingCompose = false }
    func showSearch() { isShowingSearch = true }
    func hideSearch() { isShowingSearch = false }
    func showConnectionRequests() { isShowingConnectionRequests = true }
    func hideConnectionRequests() { isShowingConnectionRequests = false }
    func showNotifications() { isShowingNotifications = true }
    func hideNotifications() { isShowingNotifications = false }
    func showProfile() { isShowingProfile = true }
    func hideProfile() { isShowingProfile = false }
    
    @MainActor
    func fetchCurrentUserPhoto() async {
        do {
            guard let token = KeychainHelper.read() else { return }
            
            var req = URLRequest(url: AuthService.baseURL.appendingPathComponent("/user/me"))
            req.httpMethod = "GET"
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let photoKey = json["profilePhoto"] as? String {
                    currentUserPhotoKey = photoKey
                }
                if let userId = json["id"] as? String {
                    currentUserId = userId
                }
            }
        } catch {
            print("❌ Failed to fetch current user photo: \(error)")
        }
    }
}
