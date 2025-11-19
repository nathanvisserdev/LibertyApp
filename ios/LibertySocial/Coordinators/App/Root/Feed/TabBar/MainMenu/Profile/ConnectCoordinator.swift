
import SwiftUI

final class ConnectCoordinator {
    private let TokenProvider: TokenProviding
    private let AuthManagerBadName: AuthManaging
    private let firstName: String
    private let userId: String
    private let isPrivate: Bool
    
    init(firstName: String,
         userId: String,
         isPrivate: Bool,
         TokenProvider: TokenProviding = AuthManager.shared,
         AuthManagerBadName: AuthManaging = AuthManager.shared) {
        self.firstName = firstName
        self.userId = userId
        self.isPrivate = isPrivate
        self.TokenProvider = TokenProvider
        self.AuthManagerBadName = AuthManagerBadName
    }
    
    func start() -> some View {
        let model = ConnectModel(AuthManagerBadName: AuthManagerBadName)
        let viewModel = ConnectViewModel(model: model, userId: userId)
        return ConnectView(viewModel: viewModel, firstName: firstName, userId: userId, isPrivate: isPrivate)
    }
}
