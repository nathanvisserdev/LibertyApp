
import Foundation

struct SubnetListModel {
    
    private let subnetSession: SubnetSession
    private let TokenProvider: TokenProviding
    
    init(subnetSession: SubnetSession, TokenProvider: TokenProviding) {
        self.subnetSession = subnetSession
        self.TokenProvider = TokenProvider
    }
    
    func fetchSubnets() async throws -> [Subnet] {
        return try await subnetSession.getUserSubnets()
    }
    
    func deleteSubnet(subnetId: String) async throws {
        guard let url = URL(string: "\(AppConfig.baseURL)/subnets/\(subnetId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let token = try TokenProvider.getAuthToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 204 else {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data))?["error"] ?? "Failed to delete subnet"
            throw NSError(domain: "SubnetListModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
    
    func updateSubnetOrdering(subnetId: String, ordering: Int) async throws {
        guard let url = URL(string: "\(AppConfig.baseURL)/subnets/\(subnetId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let token = try TokenProvider.getAuthToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body = ["ordering": ordering]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = (try? JSONDecoder().decode([String: String].self, from: data))?["error"] ?? "Failed to update subnet ordering"
            throw NSError(domain: "SubnetListModel", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
}
