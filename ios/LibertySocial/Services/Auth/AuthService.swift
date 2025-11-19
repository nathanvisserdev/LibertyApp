
import Foundation

extension Notification.Name {
    static let userDidLogout = Notification.Name("userDidLogout")
}

protocol TokenProviding {
    func getAuthToken() throws -> String
    func getCurrentUserIsPrivate() async throws -> Bool
}

protocol AuthManaging {
    func signup(_ request: SignupRequest) async throws -> String
    func login(email: String, password: String) async throws -> String
    func fetchCurrentUser() async throws -> [String: Any]
    func fetchCurrentUserTyped() async throws -> APIUser
    func fetchFeed() async throws -> [FeedItem]
    func fetchIncomingConnectionRequests() async throws -> [ConnectionRequestRow]
    func createConnectionRequest(requestedId: String, type: String) async throws -> ConnectionRequestResponse
    func acceptConnectionRequest(requestId: String) async throws
    func declineConnectionRequest(requestId: String) async throws
    func searchUsers(query: String) async throws -> SearchResponse
    func fetchUserProfile(userId: String) async throws -> UserProfile
    func fetchConnections() async throws -> [Connection]
    func deleteToken()
    func logout()
}

struct APIUser: Decodable { 
    let id: String
    let email: String
    let isPrivate: Bool
}

@MainActor
final class AuthManager: AuthManaging, TokenProviding {
    static let baseURL = AppConfig.baseURL
    static let shared = AuthManager()
    private var cachedUser: APIUser?
    
    private func getToken() throws -> String {
        guard let token = KeychainHelper.read() else {
            throw APIError.unauthorized
        }
        return token
    }
    
    func getAuthToken() throws -> String {
        return try getToken()
    }
    
    func getCurrentUserIsPrivate() async throws -> Bool {
        let user = try await fetchCurrentUserTyped()
        return user.isPrivate
    }
    
    private func saveToken(_ token: String) throws {
        try KeychainHelper.save(token: token)
    }
    
    func deleteToken() {
        KeychainHelper.delete()
    }
    
    func logout() {
        KeychainHelper.delete()
        
        cachedUser = nil
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
    }
    
    func signup(_ request: SignupRequest) async throws -> String {
        let url = AuthManager.baseURL.appendingPathComponent("/signup")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        req.httpBody = try encoder.encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.unknown(nil)
        }
        
        guard http.statusCode == 201 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Signup failed"
            throw APIError.server(errorMessage)
        }
        
        let decoded = try JSONDecoder().decode(SignupResponse.self, from: data)
        try saveToken(decoded.accessToken)
        return decoded.accessToken
    }

    func login(email: String, password: String) async throws -> String {
        let payload = ["email": email, "password": password]
        let data = try JSONSerialization.data(withJSONObject: payload)
        var req = URLRequest(url: AuthManager.baseURL.appendingPathComponent("/login"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = data

        let (respData, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw APIError.unknown(nil) }
        guard (200..<300).contains(http.statusCode) else {
            let msg = String(data: respData, encoding: .utf8) ?? "Server error"
            throw APIError.server(msg)
        }

        let decoded = try JSONDecoder().decode(LoginResponse.self, from: respData)
        try saveToken(decoded.accessToken)
        return decoded.accessToken
    }

    func fetchCurrentUser() async throws -> [String: Any] {
        let token = try getToken()
        
        var req = URLRequest(url: AuthManager.baseURL.appendingPathComponent("/user/me"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.unauthorized
        }
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return json ?? [:]
    }

    func fetchCurrentUserTyped() async throws -> APIUser {
        let token = try getToken()
        
        var req = URLRequest(url: AuthManager.baseURL.appendingPathComponent("/user/me"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { throw APIError.unauthorized }
        do { return try JSONDecoder().decode(APIUser.self, from: data) }
        catch { throw APIError.decoding }
    }

    func fetchFeed() async throws -> [FeedItem] {
        let token = try getToken()
        
        var req = URLRequest(url: AuthManager.baseURL.appendingPathComponent("/feed"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.server("Failed to load feed")
        }
        do { return try JSONDecoder().decode([FeedItem].self, from: data) }
        catch { throw APIError.decoding }
    }

    func fetchIncomingConnectionRequests() async throws -> [ConnectionRequestRow] {
        let token = try getToken()
        
        var req = URLRequest(url: AuthManager.baseURL.appendingPathComponent("/connections/pending/incoming"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.server("Failed to load incoming requests")
        }
        
        struct Response: Decodable {
            let incomingRequests: [ConnectionRequestRow]
        }
        
        do { 
            let decoded = try JSONDecoder().decode(Response.self, from: data)
            return decoded.incomingRequests
        }
        catch { throw APIError.decoding }
    }

    func createConnectionRequest(requestedId: String, type: String) async throws -> ConnectionRequestResponse {
        let token = try getToken()
        
        let requestType = type == "IS_FOLLOWING" ? "FOLLOW" : type
        let body = ["requestedId": requestedId, "requestType": requestType]
        let data = try JSONSerialization.data(withJSONObject: body)

        var req = URLRequest(url: AuthManager.baseURL.appendingPathComponent("/connections/request"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.httpBody = data

        let (respData, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let msg = String(data: respData, encoding: .utf8) ?? "Failed to create request"
            throw APIError.server(msg)
        }
        do { return try JSONDecoder().decode(ConnectionRequestResponse.self, from: respData) }
        catch { 
            print("Failed to decode response. Raw data: \(String(data: respData, encoding: .utf8) ?? "nil")")
            throw APIError.decoding 
        }
    }

    func searchUsers(query: String) async throws -> SearchResponse {
        let token = try getToken()
        
        var components = URLComponents(url: AuthManager.baseURL.appendingPathComponent("/search/users"), resolvingAgainstBaseURL: true)
        components?.queryItems = [URLQueryItem(name: "q", value: query)]
        
        guard let url = components?.url else { throw APIError.badURL }
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.server("Failed to search users")
        }
        
        do { return try JSONDecoder().decode(SearchResponse.self, from: data) }
        catch { throw APIError.decoding }
    }

    func fetchUserProfile(userId: String) async throws -> UserProfile {
        let token = try getToken()
        
        var req = URLRequest(url: AuthManager.baseURL.appendingPathComponent("/users/\(userId)"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.server("Failed to fetch user profile")
        }
        
        do { return try JSONDecoder().decode(UserProfile.self, from: data) }
        catch { throw APIError.decoding }
    }
    
    func acceptConnectionRequest(requestId: String) async throws {
        let token = try getToken()
        
        var req = URLRequest(url: AuthManager.baseURL.appendingPathComponent("/connections/\(requestId)/accept"))
        req.httpMethod = "POST"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Failed to accept request"
            throw APIError.server(errorMessage)
        }
    }
    
    func declineConnectionRequest(requestId: String) async throws {
        let token = try getToken()
        
        var req = URLRequest(url: AuthManager.baseURL.appendingPathComponent("/connections/\(requestId)/decline"))
        req.httpMethod = "POST"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Failed to decline request"
            throw APIError.server(errorMessage)
        }
    }
    
    func fetchConnections() async throws -> [Connection] {
        let token = try getToken()
        
        var req = URLRequest(url: AuthManager.baseURL.appendingPathComponent("/connections"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.server("Failed to load connections")
        }
        
        struct Response: Decodable {
            let connectionsList: [Connection]
        }
        
        do {
            let decoded = try JSONDecoder().decode(Response.self, from: data)
            return decoded.connectionsList
        }
        catch {
            throw APIError.decoding
        }
    }
}
