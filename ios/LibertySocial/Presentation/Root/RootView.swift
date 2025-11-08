
import SwiftUI

struct RootView: View {
    @StateObject private var viewModel: RootViewModel
    private let makeContent: (Bool) -> AnyView

    init(
            viewModel: RootViewModel,
            makeContent: @escaping (Bool) -> AnyView
        ) {
            _viewModel = StateObject(wrappedValue: viewModel)
            self.makeContent = makeContent
        }

    var body: some View {
        makeContent(viewModel.isAuthenticated)
    }
}

