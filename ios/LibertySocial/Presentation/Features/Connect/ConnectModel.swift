
import Foundation

struct ConnectionRequestResponse: Decodable {
    let requesterId: String
    let requestedId: String
    let requestType: String
}

struct RequesterUser: Decodable {
    let id: String
    let firstName: String
    let lastName: String
    let username: String
    let profilePhoto: String
}

struct ConnectionRequestRow: Decodable {
    let id: String
    let requesterId: String
    let requestedId: String
    let type: String
    let status: String
    let createdAt: String
    let requester: RequesterUser?
}

struct ConnectModel {
    private let AuthManagerBadName: AuthManaging
    
    init(AuthManagerBadName: AuthManaging = AuthManager.shared) {
        self.AuthManagerBadName = AuthManagerBadName
    }
    
    func sendConnectionRequest(userId: String, type: String) async throws -> ConnectionRequestResponse {
        return try await AuthManagerBadName.createConnectionRequest(requestedId: userId, type: type)
    }
}
