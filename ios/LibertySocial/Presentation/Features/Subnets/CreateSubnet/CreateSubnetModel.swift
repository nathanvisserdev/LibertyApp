
import Foundation

struct CreateSubnetRequest: Codable {
    let name: String
    let description: String?
    let visibility: String
}

struct CreateSubnetResponse: Codable {
    let id: String
    let name: String
    let slug: String
    let description: String?
    let visibility: String
    let isDefault: Bool
    let ownerId: String
}

struct CreateSubnetModel {
    
    private let TokenProvider: TokenProviding
    
    init(TokenProvider: TokenProviding) {
        self.TokenProvider = TokenProvider
    }
    
    func createSubnet(name: String, description: String?, visibility: String) async throws -> CreateSubnetResponse {
        let url = URL(string: "/subnets", relativeTo: AppConfig.baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let token = try TokenProvider.getAuthToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body = CreateSubnetRequest(
            name: name,
            description: description,
            visibility: visibility
        )
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        
        if (200...299).contains(http.statusCode) {
            return try JSONDecoder().decode(CreateSubnetResponse.self, from: data)
        } else {
            if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
               let errorMessage = errorResponse["error"] {
                throw NSError(domain: "CreateSubnetModel", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            }
            throw NSError(domain: "CreateSubnetModel", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to create subnet"])
        }
    }
    
    func setDefaultSubnet(subnetId: String) async throws {
        let url = URL(string: "/user/default-subnet", relativeTo: AppConfig.baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let token = try TokenProvider.getAuthToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body = ["subnetId": subnetId]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        
        if !(200...299).contains(http.statusCode) {
            throw NSError(domain: "CreateSubnetModel", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to set default subnet"])
        }
    }
}
