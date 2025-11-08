
import Foundation
import Combine

@MainActor
final class ConnectionsListViewModel: ObservableObject {
    private let model: ConnectionsListModel
    
    private let onUserSelected: (String) -> Void
    
    @Published var connections: [Connection] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init(model: ConnectionsListModel = ConnectionsListModel(),
         onUserSelected: @escaping (String) -> Void) {
        self.model = model
        self.onUserSelected = onUserSelected
    }
    
    
    func selectUser(userId: String) {
        onUserSelected(userId)
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
