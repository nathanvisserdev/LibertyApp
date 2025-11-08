
import Foundation

struct LoginResponse: Decodable { let accessToken: String }

struct LoginModel {
    private let authManager: AuthManaging
    
    init(authManager: AuthManaging) {
        self.authManager = authManager
    }
    
    func login(email: String, password: String) async throws {
        _ = try await authManager.login(email: email, password: password)
    }
    
    func fetchCurrentUser() async throws -> [String: Any] {
        return try await authManager.fetchCurrentUser()
    }
    
    func deleteToken() {
        authManager.deleteToken()
    }
}
