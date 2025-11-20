
import Foundation

struct SuggestedGroupsModel {
    private let TokenProvider: TokenProviding
    private let AuthManagerBadName: AuthManaging
    
    init(TokenProvider: TokenProviding = AuthManager.shared, AuthManagerBadName: AuthManaging = AuthManager.shared) {
        self.TokenProvider = TokenProvider
        self.AuthManagerBadName = AuthManagerBadName
    }
    
    func fetchCurrentUserId() async throws -> String {
        let currentUser = try await AuthManagerBadName.fetchCurrentUserTyped()
        return currentUser.id
    }
    
    func fetchJoinableGroups(userId: String) async throws -> [UserGroup] {
        guard let url = URL(string: "\(AppConfig.baseURL)/users/\(userId)/groups") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let token = try TokenProvider.getAuthToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let responseData = try decoder.decode(UserGroupsResponse.self, from: data)
            return responseData.groups
        } else {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data)["error"]) ?? "Failed to fetch groups"
            throw NSError(domain: "SuggestedGroupsModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
}

