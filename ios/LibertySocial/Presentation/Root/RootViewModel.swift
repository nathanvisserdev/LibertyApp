
import Foundation
import Combine
import SwiftUI

@MainActor
final class RootViewModel: ObservableObject {
    
    var onAuthenticationInvalidated: (() -> Void)?
    
    @Published var isAuthenticated: Bool {
        didSet {
            if !isAuthenticated && oldValue {
                onAuthenticationInvalidated?()
            }
        }
    }
    
    init(isAuthenticated: Bool) {
        self.isAuthenticated = isAuthenticated
    }
}
