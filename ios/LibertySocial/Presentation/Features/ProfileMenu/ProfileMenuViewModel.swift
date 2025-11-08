
import Foundation
import Combine
import SwiftUI

@MainActor
final class ProfileMenuViewModel: ObservableObject {
    private let model: ProfileMenuModel
    private let onProfileTapped: (String) -> Void
    private let userId: String
    
    var onShowProfile: () -> AnyView = { AnyView(EmptyView()) }
    
    @Published var showSettings: Bool = false
    @Published var isShowingProfile: Bool = false
    
    init(model: ProfileMenuModel,
         userId: String,
         onProfileTapped: @escaping (String) -> Void) {
        self.model = model
        self.userId = userId
        self.onProfileTapped = onProfileTapped
    }
    
    func tapProfile() {
        isShowingProfile = true
        onProfileTapped(userId)
    }
    
    func tapSettings() {
        showSettings = true
    }
}
