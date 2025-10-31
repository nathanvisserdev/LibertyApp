//
//  CreateGroupModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-27.
//

import Foundation

// MARK: - Domain Models
enum GroupType: String, CaseIterable {
    case autocratic = "AUTOCRATIC"
    case roundTable = "ROUND_TABLE"
    
    var displayName: String {
        switch self {
        case .autocratic: return "Autocratic"
        case .roundTable: return "Round Table"
        }
    }
    
    var description: String {
        switch self {
        case .autocratic: return "Group admin has full control"
        case .roundTable: return "Decisions made democratically by members"
        }
    }
}

enum GroupPrivacy: String, CaseIterable {
    case publicGroup = "PUBLIC"
    case privateGroup = "PRIVATE"
    case personalGroup = "PERSONAL"
    
    var displayName: String {
        switch self {
        case .publicGroup: return "Public"
        case .privateGroup: return "Private"
        case .personalGroup: return "Personal"
        }
    }
    
    var description: String {
        switch self {
        case .publicGroup: return "Publicly visible to everyone"
        case .privateGroup: return "Only members can see content"
        case .personalGroup: return "Only acquaintances can join"
        }
    }
    
    var iconName: String {
        switch self {
        case .publicGroup: return "lock.open"
        case .privateGroup: return "lock"
        case .personalGroup: return "lock.heart"
        }
    }
}

struct RoundTableAdmin: Identifiable {
    let id: String
    let userId: String
    let firstName: String
    let lastName: String
    let username: String
    let profilePhoto: String?
    var isModerator: Bool
    
    init(from connection: Connection, isModerator: Bool = true) {
        self.id = connection.id
        self.userId = connection.userId
        self.firstName = connection.firstName
        self.lastName = connection.lastName
        self.username = connection.username
        self.profilePhoto = connection.profilePhoto
        self.isModerator = isModerator
    }
}

enum ElectionCycle: String, CaseIterable {
    case threeMonths = "THREE_MONTHS"
    case sixMonths = "SIX_MONTHS"
    case oneYear = "ONE_YEAR"
    case twoYears = "TWO_YEARS"
    case fourYears = "FOUR_YEARS"
}

// MARK: - DTOs
struct CreateGroupRequest: Codable {
    let name: String
    let description: String?
    let groupType: String
    let groupPrivacy: String
    let isHidden: Bool
}

struct CreateRoundTableGroupRequest {
    let name: String
    let description: String?
    let groupPrivacy: String
    let requiresApproval: Bool
    let viceChairId: String
    let admins: [[String: Any]]
    let electionCycle: String?
}

struct CreateGroupResponse: Codable {
    let id: String
    let name: String
    let groupType: String
    let groupPrivacy: String
    let isHidden: Bool
}

// MARK: - Model
struct CreateGroupModel {
    private let authSession: AuthSession
    private let authService: AuthServiceProtocol
    
    init(authSession: AuthSession = AuthService.shared, authService: AuthServiceProtocol = AuthService.shared) {
        self.authSession = authSession
        self.authService = authService
    }
    
    /// Create autocratic group
    func createGroup(name: String, description: String?, groupType: String, groupPrivacy: String, isHidden: Bool) async throws -> CreateGroupResponse {
        guard let url = URL(string: "\(AppConfig.baseURL)/groups") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let token = try authSession.getAuthToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body = CreateGroupRequest(
            name: name,
            description: description,
            groupType: groupType,
            groupPrivacy: groupPrivacy,
            isHidden: isHidden
        )
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        if (200...299).contains(httpResponse.statusCode) {
            return try JSONDecoder().decode(CreateGroupResponse.self, from: data)
        } else {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data)["error"]) ?? "Unknown error"
            throw NSError(domain: "CreateGroupModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
    
    /// Create round table group
    func createRoundTableGroup(request: CreateRoundTableGroupRequest) async throws -> CreateGroupResponse {
        guard let url = URL(string: "\(AppConfig.baseURL)/groups") else {
            throw URLError(.badURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let token = try authSession.getAuthToken()
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        var body: [String: Any] = [
            "name": request.name,
            "groupType": "ROUND_TABLE",
            "groupPrivacy": request.groupPrivacy,
            "requiresApproval": request.requiresApproval,
            "viceChairId": request.viceChairId,
            "admins": request.admins
        ]
        
        if let description = request.description, !description.isEmpty {
            body["description"] = description
        }
        
        if let electionCycle = request.electionCycle {
            body["electionCycle"] = electionCycle
        }
        
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            return try JSONDecoder().decode(CreateGroupResponse.self, from: data)
        } else {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data))?["error"] ?? "Unknown error"
            throw NSError(domain: "CreateGroupModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
    
    /// Fetch user connections - used for selecting Round Table admins
    func fetchConnections() async throws -> [Connection] {
        return try await authService.fetchConnections()
    }
}
