
import Foundation
import Combine
import SwiftUI

@MainActor
final class ConnectionsListViewModel: ObservableObject {
    private let model: ConnectionsListModel
    
    private let onUserSelected: (String) -> Void
    
    @Published var connections: [Connection] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isShowingProfile: Bool = false
    @Published var selectedUserId: String?
    
    var makeProfileView: ((String) -> AnyView)?
    
    init(model: ConnectionsListModel,
         onUserSelected: @escaping (String) -> Void) {
        self.model = model
        self.onUserSelected = onUserSelected
    }
    
    
    func selectUser(userId: String) {
        selectedUserId = userId
        isShowingProfile = true
        onUserSelected(userId)
    }
    
    func hideProfile() {
        isShowingProfile = false
        selectedUserId = nil
    }
    
    func loadConnections() async {
        isLoading = true
        errorMessage = nil
        
        do {
            connections = try await model.fetchConnections()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
