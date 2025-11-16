
import Foundation

class CommentHTTPService: CommentService {
    private let baseURL: URL
    private let TokenProvider: TokenProviding
    
    init(baseURL: URL = AppConfig.baseURL, TokenProvider: TokenProviding) {
        self.baseURL = baseURL
        self.TokenProvider = TokenProvider
    }
    
    func fetch(postId: String, cursor: String?) async throws -> ([CommentItem], String?) {
        guard var urlComponents = URLComponents(string: "\(baseURL.absoluteString)/posts/\(postId)/comments") else {
            throw CommentServiceError.invalidURL
        }
        
        if let cursor = cursor {
            urlComponents.queryItems = [URLQueryItem(name: "cursor", value: cursor)]
        }
        
        guard let url = urlComponents.url else {
            throw CommentServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CommentServiceError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw CommentServiceError.unauthorized
            }
            throw CommentServiceError.serverError(httpResponse.statusCode)
        }
        
        struct Response: Codable {
            let comments: [CommentItem]
            let nextCursor: String?
        }
        
        let decoded = try JSONDecoder().decode(Response.self, from: data)
        return (decoded.comments, decoded.nextCursor)
    }
    
    func create(postId: String, content: String) async throws -> CommentItem {
        guard let url = URL(string: "\(baseURL.absoluteString)/posts/\(postId)/comments") else {
            throw CommentServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = try? TokenProvider.getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        struct CreateRequest: Codable {
            let content: String
        }
        
        let body = CreateRequest(content: content)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CommentServiceError.invalidResponse
        }
        
        guard httpResponse.statusCode == 201 || httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw CommentServiceError.unauthorized
            }
            throw CommentServiceError.serverError(httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(CommentItem.self, from: data)
    }
    
    func update(commentId: String, content: String) async throws -> CommentItem {
        guard let url = URL(string: "\(baseURL.absoluteString)/comments/\(commentId)") else {
            throw CommentServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = try? TokenProvider.getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        struct UpdateRequest: Codable {
            let content: String
        }
        
        let body = UpdateRequest(content: content)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CommentServiceError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw CommentServiceError.unauthorized
            }
            throw CommentServiceError.serverError(httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(CommentItem.self, from: data)
    }
    
    func delete(commentId: String) async throws {
        guard let url = URL(string: "\(baseURL.absoluteString)/comments/\(commentId)") else {
            throw CommentServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        if let token = try? TokenProvider.getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CommentServiceError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 204 else {
            if httpResponse.statusCode == 401 {
                throw CommentServiceError.unauthorized
            }
            throw CommentServiceError.serverError(httpResponse.statusCode)
        }
    }
}

enum CommentServiceError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(Int)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized - please log in again"
        case .serverError(let code):
            return "Server error: \(code)"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
