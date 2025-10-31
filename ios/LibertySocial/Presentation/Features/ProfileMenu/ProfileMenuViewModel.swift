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
    
    // MARK: - Published (UI State)
    @Published var showProfile: Bool = false
    @Published var showSettings: Bool = false
    
    // MARK: - Init
    init(model: ProfileMenuModel = ProfileMenuModel()) {
        self.model = model
    }
    
    // MARK: - Intents (User Actions)
    func tapProfile() {
        showProfile = true
    }
    
    func tapSettings() {
        showSettings = true
    }
}
