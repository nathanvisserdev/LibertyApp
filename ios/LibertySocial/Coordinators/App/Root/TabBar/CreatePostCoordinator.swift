
import SwiftUI
import Combine

@MainActor
final class CreatePostCoordinator: ObservableObject {
    
    
    func start() -> some View {
        let viewModel = CreatePostViewModel()
        return CreatePostView(viewModel: viewModel)
    }
}
