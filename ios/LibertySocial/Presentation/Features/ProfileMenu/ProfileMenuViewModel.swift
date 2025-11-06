//
//  ProfileMenuViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-28.
//

import Foundation
import Combine

@MainActor
final class ProfileMenuViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let model: ProfileMenuModel
    
    // MARK: - Callbacks
    private let onProfileTapped: (String) -> Void
    
    // MARK: - Published (UI State)
    @Published var showSettings: Bool = false
    
    // MARK: - Private State
    private let userId: String
    
    // MARK: - Init
    init(model: ProfileMenuModel = ProfileMenuModel(),
         userId: String,
         onProfileTapped: @escaping (String) -> Void) {
        self.model = model
        self.userId = userId
        self.onProfileTapped = onProfileTapped
    }
    
    // MARK: - Intents (User Actions)
    func tapProfile() {
        onProfileTapped(userId)
    }
    
    func tapSettings() {
        showSettings = true
    }
}
