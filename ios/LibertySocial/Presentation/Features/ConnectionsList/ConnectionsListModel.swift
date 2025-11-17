
import Foundation

struct Connection: Decodable, Identifiable {
    let id: String
    let userId: String
    let firstName: String
    let lastName: String
    let username: String
    let profilePhoto: String?
    let type: String
    let createdAt: String
}

struct ConnectionsListModel {
    private let AuthManagerBadName: AuthManaging
    
    init(AuthManagerBadName: AuthManaging) {
        self.AuthManagerBadName = AuthManagerBadName
    }
    
    func fetchConnections() async throws -> [Connection] {
        return try await AuthManagerBadName.fetchConnections()
    }
}
