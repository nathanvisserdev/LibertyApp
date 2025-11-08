
import SwiftUI

final class AddSubnetMembersCoordinator {
    private let TokenProvider: TokenProviding
    private let AuthManagerBadName: AuthManaging
    private let subnetId: String
    
    init(subnetId: String,
         TokenProvider: TokenProviding = AuthManager.shared,
         AuthManagerBadName: AuthManaging = AuthManager.shared) {
        self.subnetId = subnetId
        self.TokenProvider = TokenProvider
        self.AuthManagerBadName = AuthManagerBadName
    }
    
    func start() -> some View {
        let model = AddSubnetMembersModel(TokenProvider: TokenProvider)
        let viewModel = AddSubnetMembersViewModel(model: model)
        return AddSubnetMembersView(viewModel: viewModel, subnetId: subnetId)
    }
}
