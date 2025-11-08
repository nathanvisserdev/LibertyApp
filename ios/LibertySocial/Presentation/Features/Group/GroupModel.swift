
import Foundation

struct GroupModel {
    private let TokenProvider: TokenProviding
    private let AuthManagerBadName: AuthManaging
    
    init(TokenProvider: TokenProviding = AuthManager.shared, AuthManagerBadName: AuthManaging = AuthManager.shared) {
        self.TokenProvider = TokenProvider
        self.AuthManagerBadName = AuthManagerBadName
    }
    
}
