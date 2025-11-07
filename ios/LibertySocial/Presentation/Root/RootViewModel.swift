//
//  RootViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-07.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class RootViewModel: ObservableObject {
    private let model: RootModel
    
    var onAuthenticationInvalidated: (() -> Void)?
    var onShowAuthenticatedContent: (() -> AnyView)?
    var onShowLoginContent: (() -> AnyView)?
    
    @Published var isAuthenticated: Bool {
        didSet {
            if !isAuthenticated && oldValue {
                onAuthenticationInvalidated?()
            }
        }
    }
    
    var contentView: AnyView {
        if isAuthenticated {
            return onShowAuthenticatedContent?() ?? AnyView(EmptyView())
        } else {
            return onShowLoginContent?() ?? AnyView(EmptyView())
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
