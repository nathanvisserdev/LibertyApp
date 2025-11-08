
import SwiftUI

final class CreateSubnetCoordinator {
    
    init() {
    }
    
    func start() -> some View {
        let viewModel = CreateSubnetViewModel()
        return CreateSubnetView(viewModel: viewModel)
    }
}
