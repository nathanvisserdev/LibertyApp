
import Foundation
import Combine

@MainActor
class NotificationViewModel: ObservableObject {
    private let model: NotificationModel
    
    @Published var connectionRequests: [ConnectionRequestRow] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init(model: NotificationModel = NotificationModel()) {
        self.model = model
    }
    
    func fetchIncomingConnectionRequests() async {
        isLoading = true
        errorMessage = nil
        
        do {
            connectionRequests = try await model.fetchIncomingConnectionRequests()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
