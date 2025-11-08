
import Foundation
import Combine
import SwiftUI

@MainActor
final class SearchViewModel: ObservableObject {
    private let model: SearchModel
    private let onUserSelected: (String) -> Void
    
    var onShowProfile: () -> AnyView = { AnyView(EmptyView()) }
    
    @Published var query: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var users: [SearchUser] = []
    @Published var groups: [SearchGroup] = []
    @Published var isShowingProfile: Bool = false
    
    init(model: SearchModel,
         onUserSelected: @escaping (String) -> Void) {
        self.model = model
        self.onUserSelected = onUserSelected
    }

    func selectUser(userId: String) {
        isShowingProfile = true
        onUserSelected(userId)
    }
    
    func performSearch() async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedQuery.isEmpty else {
            users = []
            groups = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await model.searchUsers(query: trimmedQuery)
            users = result.users
            groups = result.groups
        } catch {
            errorMessage = error.localizedDescription
            users = []
            groups = []
        }
        
        isLoading = false
    }
}
