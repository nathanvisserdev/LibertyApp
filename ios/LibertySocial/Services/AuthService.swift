//
//  AuthService.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-06.
//

import Foundation

protocol AuthServiceProtocol {
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
    func createGroup(name: String, description: String?, groupType: String, groupPrivacy: String, isHidden: Bool) async throws -> CreateGroupResponse
    func createRoundTableGroup(name: String, groupPrivacy: String, viceChairId: String, admins: [[String: Any]], electionCycle: String?) async throws
}

struct APIUser: Decodable { let id: String; let email: String }

@MainActor
final class AuthService: AuthServiceProtocol {
    static let baseURL = AppConfig.baseURL
    static let shared = AuthService()
    
    // MARK: - Token Management (Private - isolated to AuthService)
    private func getToken() throws -> String {
        guard let token = KeychainHelper.read() else {
            throw APIError.unauthorized
        }
        return token
    }
    
    private func saveToken(_ token: String) throws {
        try KeychainHelper.save(token: token)
    }
    
    func deleteToken() {
        KeychainHelper.delete()
    }
    
    // MARK: - Signup (returns JWT and saves it)
    func signup(_ request: SignupRequest) async throws -> String {
        let url = AuthService.baseURL.appendingPathComponent("/signup")
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

    // MARK: - Login (returns JWT and saves it)
    func login(email: String, password: String) async throws -> String {
        let payload = ["email": email, "password": password]
        let data = try JSONSerialization.data(withJSONObject: payload)
        var req = URLRequest(url: AuthService.baseURL.appendingPathComponent("/login"))
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

    // MARK: - /user/me (gets token internally)
    func fetchCurrentUser() async throws -> [String: Any] {
        let token = try getToken()
        
        var req = URLRequest(url: AuthService.baseURL.appendingPathComponent("/user/me"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.unauthorized
        }
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return json ?? [:]
    }

    // Typed variant
    func fetchCurrentUserTyped() async throws -> APIUser {
        let token = try getToken()
        
        var req = URLRequest(url: AuthService.baseURL.appendingPathComponent("/user/me"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { throw APIError.unauthorized }
        do { return try JSONDecoder().decode(APIUser.self, from: data) }
        catch { throw APIError.decoding }
    }

    // MARK: - Feed
    func fetchFeed() async throws -> [FeedItem] {
        let token = try getToken()
        
        var req = URLRequest(url: AuthService.baseURL.appendingPathComponent("/feed"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.server("Failed to load feed")
        }
        do { return try JSONDecoder().decode([FeedItem].self, from: data) }
        catch { throw APIError.decoding }
    }

    // MARK: - Connections (incoming requests)
    func fetchIncomingConnectionRequests() async throws -> [ConnectionRequestRow] {
        let token = try getToken()
        
        var req = URLRequest(url: AuthService.baseURL.appendingPathComponent("/connections/pending/incoming"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.server("Failed to load incoming requests")
        }
        
        // Server returns { incomingRequests: [...] }
        struct Response: Decodable {
            let incomingRequests: [ConnectionRequestRow]
        }
        
        do { 
            let decoded = try JSONDecoder().decode(Response.self, from: data)
            return decoded.incomingRequests
        }
        catch { throw APIError.decoding }
    }

    // Create a connection request
    func createConnectionRequest(requestedId: String, type: String) async throws -> ConnectionRequestResponse {
        let token = try getToken()
        
        // Map IS_FOLLOWING to FOLLOW for server compatibility
        let requestType = type == "IS_FOLLOWING" ? "FOLLOW" : type
        let body = ["requestedId": requestedId, "requestType": requestType]
        let data = try JSONSerialization.data(withJSONObject: body)

        var req = URLRequest(url: AuthService.baseURL.appendingPathComponent("/connections/request"))
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

    // MARK: - Search
    func searchUsers(query: String) async throws -> SearchResponse {
        let token = try getToken()
        
        var components = URLComponents(url: AuthService.baseURL.appendingPathComponent("/search/users"), resolvingAgainstBaseURL: true)
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

    // MARK: - Profile
    func fetchUserProfile(userId: String) async throws -> UserProfile {
        let token = try getToken()
        
        var req = URLRequest(url: AuthService.baseURL.appendingPathComponent("/users/\(userId)"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.server("Failed to fetch user profile")
        }
        
        do { return try JSONDecoder().decode(UserProfile.self, from: data) }
        catch { throw APIError.decoding }
    }
    
    // MARK: - Connection Request Actions
    func acceptConnectionRequest(requestId: String) async throws {
        let token = try getToken()
        
        var req = URLRequest(url: AuthService.baseURL.appendingPathComponent("/connections/\(requestId)/accept"))
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
        
        var req = URLRequest(url: AuthService.baseURL.appendingPathComponent("/connections/\(requestId)/decline"))
        req.httpMethod = "POST"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Failed to decline request"
            throw APIError.server(errorMessage)
        }
    }
    
    // MARK: - Connections List
    func fetchConnections() async throws -> [Connection] {
        let token = try getToken()
        
        var req = URLRequest(url: AuthService.baseURL.appendingPathComponent("/connections"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.server("Failed to load connections")
        }
        
        // Server returns { connectionsList: [...] }
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
    
    // MARK: - Create Group
    func createGroup(name: String, description: String?, groupType: String, groupPrivacy: String, isHidden: Bool) async throws -> CreateGroupResponse {
        return try await CreateGroupModel.createGroup(
            name: name,
            description: description,
            groupType: groupType,
            groupPrivacy: groupPrivacy,
            isHidden: isHidden
        )
    }
    
    func createRoundTableGroup(name: String, groupPrivacy: String, viceChairId: String, admins: [[String: Any]], electionCycle: String?) async throws {
        let token = try getToken()
        
        let url = AppConfig.baseURL.appendingPathComponent("groups")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        var body: [String: Any] = [
            "name": name,
            "groupType": "ROUND_TABLE",
            "groupPrivacy": groupPrivacy,
            "viceChairId": viceChairId,
            "admins": admins
        ]
        
        if let electionCycle = electionCycle {
            body["electionCycle"] = electionCycle
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "AuthService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to create group"])
        }
    }
}
