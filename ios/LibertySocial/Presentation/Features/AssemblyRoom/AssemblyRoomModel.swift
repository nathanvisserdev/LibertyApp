
import Foundation

struct AssemblyRoomModel {
    private let TokenProvider: TokenProviding
    private let AuthManagerBadName: AuthManaging
    
    init(TokenProvider: TokenProviding,
         AuthManagerBadName: AuthManaging
    ) {
        self.TokenProvider = TokenProvider
        self.AuthManagerBadName = AuthManagerBadName
    }
}
