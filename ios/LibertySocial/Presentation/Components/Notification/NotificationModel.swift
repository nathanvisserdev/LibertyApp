
import Foundation

struct NotificationModel {
    private let AuthManagerBadName: AuthManaging
    
    init(AuthManagerBadName: AuthManaging = AuthManager.shared) {
        self.AuthManagerBadName = AuthManagerBadName
    }
    
    func fetchIncomingConnectionRequests() async throws -> [ConnectionRequestRow] {
        return try await AuthManagerBadName.fetchIncomingConnectionRequests()
    }
}
