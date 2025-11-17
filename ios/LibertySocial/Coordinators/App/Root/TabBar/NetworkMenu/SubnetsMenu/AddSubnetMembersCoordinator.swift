
import SwiftUI

final class AddSubnetMembersCoordinator {
    private let TokenProvider: TokenProviding
    private let AuthManagerBadName: AuthManaging
    private let subnetId: String
    private let subnetListViewModel: SubnetListViewModel
    
    init(subnetId: String,
         TokenProvider: TokenProviding,
         AuthManagerBadName: AuthManaging,
         subnetListViewModel: SubnetListViewModel) {
        self.subnetId = subnetId
        self.TokenProvider = TokenProvider
        self.AuthManagerBadName = AuthManagerBadName
        self.subnetListViewModel = subnetListViewModel
    }
    
    func start(subnetId: String) -> some View {
        let model = AddSubnetMembersModel(TokenProvider: TokenProvider)
        let viewModel = AddSubnetMembersViewModel(model: model)
        return AddSubnetMembersView(viewModel: viewModel, subnetId: subnetId)
    }
}
