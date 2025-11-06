//
//  RootViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-07.
//

import Foundation
import Combine

@MainActor
final class RootViewModel: ObservableObject {
    // MARK: - Dependencies
    private let model: RootModel
    
    /// Callback triggered when authentication transitions from true to false
    /// Set by the coordinator after initialization to avoid premature `self` capture
    var onAuthenticationInvalidated: (() -> Void)?
    
    // MARK: - Published State
    /// Authentication state injected and updated by the coordinator
    /// Never set this directly from the view - coordinator owns this state
    @Published var isAuthenticated: Bool {
        didSet {
            // Only trigger callback when authentication transitions from true to false
            // This ensures we don't fire on initialization or redundant updates
            if !isAuthenticated && oldValue {
                onAuthenticationInvalidated?()
            }
        }
    }
    
    init(model: RootModel,
         isAuthenticated: Bool,
         onAuthenticationInvalidated: (() -> Void)? = nil) {
        self.model = model
        self.isAuthenticated = isAuthenticated
        self.onAuthenticationInvalidated = onAuthenticationInvalidated
    }
}
