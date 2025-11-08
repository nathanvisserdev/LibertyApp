
import Foundation
import Combine


enum GroupInviteEvent {
    case invitesSentSuccessfully(count: Int)
    case invitesFailed(error: Error)
}


protocol GroupInviteSession {
    var inviteEvents: AnyPublisher<GroupInviteEvent, Never> { get }
    func sendInvites(groupId: String, userIds: [String]) async throws
}


@MainActor
final class GroupInviteService: GroupInviteSession {
    
    static let shared = GroupInviteService()
    
    private let TokenProvider: TokenProviding
    
    private let inviteEventsSubject = PassthroughSubject<GroupInviteEvent, Never>()
    var inviteEvents: AnyPublisher<GroupInviteEvent, Never> {
        inviteEventsSubject.eraseToAnyPublisher()
    }
    
    init(TokenProvider: TokenProviding = AuthManager.shared) {
        self.TokenProvider = TokenProvider
    }
    
    
    func sendInvites(groupId: String, userIds: [String]) async throws {
        do {
            let token = try TokenProvider.getAuthToken()
            
            guard let url = URL(string: "\(AppConfig.baseURL)/groups/\(groupId)/invite") else {
                throw URLError(.badURL)
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let body = ["userIds": userIds]
            request.httpBody = try JSONEncoder().encode(body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                inviteEventsSubject.send(.invitesSentSuccessfully(count: userIds.count))
            } else {
                let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data)["error"]) ?? "Failed to send invites"
                let error = NSError(domain: "GroupInviteService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
                inviteEventsSubject.send(.invitesFailed(error: error))
                throw error
            }
        } catch {
            inviteEventsSubject.send(.invitesFailed(error: error))
            throw error
        }
    }
}
