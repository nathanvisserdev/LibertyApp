
import SwiftUI

final class SubnetCoordinator {
    private let TokenProvider: TokenProviding
    private let subnet: Subnet
    
    init(subnet: Subnet,
         TokenProvider: TokenProviding = AuthManager.shared) {
        self.subnet = subnet
        self.TokenProvider = TokenProvider
    }
    
    func start() -> some View {
        let model = SubnetModel(TokenProvider: TokenProvider)
        let viewModel = SubnetViewModel(model: model, subnet: subnet)
        return SubnetView(viewModel: viewModel)
    }
}
