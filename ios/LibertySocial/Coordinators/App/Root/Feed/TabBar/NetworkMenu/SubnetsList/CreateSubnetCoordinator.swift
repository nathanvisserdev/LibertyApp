
import SwiftUI

final class CreateSubnetCoordinator {
    private let TokenProvider: TokenProviding
    private let subnetService: SubnetSession
    private let subnetListViewModel: SubnetsListViewModel
    
    init(TokenProvider: TokenProviding, 
         subnetService: SubnetSession,
         subnetListViewModel: SubnetsListViewModel) {
        self.TokenProvider = TokenProvider
        self.subnetService = subnetService
        self.subnetListViewModel = subnetListViewModel
    }
    
    func start() -> some View {
        let model = CreateSubnetModel(TokenProvider: TokenProvider)
        let viewModel = CreateSubnetViewModel(model: model, subnetService: subnetService)
        viewModel.makeAddSubnetMembersView = { [weak self] subnetId in
            guard let self = self else { return AnyView(EmptyView()) }
            let coordinator = AddSubnetMembersCoordinator(
                subnetId: subnetId,
                TokenProvider: self.TokenProvider,
                AuthManagerBadName: self.TokenProvider as! AuthManaging,
                subnetListViewModel: self.subnetListViewModel
            )
            return AnyView(coordinator.start(subnetId: subnetId))
        }
        return CreateSubnetView(viewModel: viewModel)
    }
}
