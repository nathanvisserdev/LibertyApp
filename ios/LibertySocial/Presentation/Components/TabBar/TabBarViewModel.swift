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
    // MARK: - Dependencies
    private let model: TabBarModel
    
    // MARK: - Published Properties (State Only)
    @Published var currentUserPhotoKey: String?
    @Published var currentUserId: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Init
    init(model: TabBarModel = TabBarModel()) {
        self.model = model
    }
    
    // MARK: - Public Methods
    
    /// Fetch current user's photo and ID from /user/me
    func fetchCurrentUserInfo() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let userInfo = try await model.fetchCurrentUserInfo()
            currentUserPhotoKey = userInfo.photoKey
            currentUserId = userInfo.userId
            isLoading = false
        } catch {
            errorMessage = "Failed to fetch current user info: \(error.localizedDescription)"
            isLoading = false
        }
    }
}
