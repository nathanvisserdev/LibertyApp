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
    @Published var currentUserPhotoKey: String?

    func showCompose() { isShowingCompose = true }
    func hideCompose() { isShowingCompose = false }
    func showSearch() { isShowingSearch = true }
    func hideSearch() { isShowingSearch = false }
    func showConnectionRequests() { isShowingConnectionRequests = true }
    func hideConnectionRequests() { isShowingConnectionRequests = false }
    
    @MainActor
    func fetchCurrentUserPhoto() async {
        do {
            guard let token = KeychainHelper.read() else { return }
            
            var req = URLRequest(url: AuthService.baseURL.appendingPathComponent("/user/me"))
            req.httpMethod = "GET"
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let photoKey = json["profilePhoto"] as? String {
                currentUserPhotoKey = photoKey
            }
        } catch {
            print("❌ Failed to fetch current user photo: \(error)")
        }
    }
}
