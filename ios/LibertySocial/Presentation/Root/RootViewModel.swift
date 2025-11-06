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
    private let model: RootModel
    private let onAuthenticationChanged: (Bool) -> Void
    
    init(model: RootModel,
         onAuthenticationChanged: @escaping (Bool) -> Void = { _ in }) {
        self.model = model
        self.onAuthenticationChanged = onAuthenticationChanged
    }
    
    func notifyAuthenticationChanged(isAuthenticated: Bool) {
        onAuthenticationChanged(isAuthenticated)
    }
}
