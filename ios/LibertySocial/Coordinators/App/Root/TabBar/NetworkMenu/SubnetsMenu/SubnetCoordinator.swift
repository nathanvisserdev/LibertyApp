
import SwiftUI

final class SubnetCoordinator {
    private let TokenProvider: TokenProviding
    private let AuthManagerBadName: AuthManaging
    private let subnetService: SubnetSession
    private let subnet: Subnet
    private let subnetListViewModel: SubnetListViewModel
    
    init(subnet: Subnet,
         TokenProvider: TokenProviding,
         AuthManagerBadName: AuthManaging,
         subnetService: SubnetSession,
         subnetListViewModel: SubnetListViewModel) {
        self.subnet = subnet
        self.TokenProvider = TokenProvider
        self.AuthManagerBadName = AuthManagerBadName
        self.subnetService = subnetService
        self.subnetListViewModel = subnetListViewModel
    }
    
    func start() -> some View {
        let model = SubnetModel(TokenProvider: TokenProvider, AuthManagerBadName: AuthManagerBadName)
        let viewModel = SubnetViewModel(model: model, subnet: subnet, subnetService: subnetService)
        viewModel.onAddSubnetMembers = { [weak self] subnetId in
            self?.handleAddSubnetMembersTap(subnetId: subnetId)
        }
        return SubnetView(viewModel: viewModel)
    }
    
    private func handleAddSubnetMembersTap(subnetId: String) -> Void {
        subnetListViewModel.navigateToAddSubnetMembersView(subnetId: subnetId)
    }
}
