
import Foundation

struct LoginResponse: Decodable { let accessToken: String }

struct LoginModel {
    private let AuthManagerBadName: AuthManaging
    
    init(AuthManagerBadName: AuthManaging = AuthManager.shared) {
        self.AuthManagerBadName = AuthManagerBadName
    }
    
    func login(email: String, password: String) async throws {
        _ = try await AuthManagerBadName.login(email: email, password: password)
    }
    
    func fetchCurrentUser() async throws -> [String: Any] {
        return try await AuthManagerBadName.fetchCurrentUser()
    }
    
    func deleteToken() {
        AuthManager.shared.deleteToken()
    }
}
