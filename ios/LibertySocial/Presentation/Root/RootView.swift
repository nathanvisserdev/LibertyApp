
import SwiftUI

struct RootView: View {
    @ObservedObject private var viewModel: RootViewModel
    private let makeContent: (Bool) -> AnyView

    init(
            viewModel: RootViewModel,
            makeContent: @escaping (Bool) -> AnyView
        ) {
            self.viewModel = viewModel
            self.makeContent = makeContent
        }

    var body: some View {
        makeContent(viewModel.isAuthenticated)
    }
}

