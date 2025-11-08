
import SwiftUI
import Combine

enum FollowingListRoute: Hashable {
    case profile(String)
}

final class FollowingNavPathStore: ObservableObject {
    @Published var path = NavigationPath()
}

@MainActor
final class FollowingListCoordinator: ObservableObject {
    private let nav = FollowingNavPathStore()
    
    private let userId: String
    private let authenticationManager: AuthManaging
    private let tokenProvider: TokenProviding

    init(userId: String,
         authenticationManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.userId = userId
        self.authenticationManager = authenticationManager
        self.tokenProvider = tokenProvider
    }
    
    func start() -> some View {
        FollowingStackView(
            nav: nav,
            userId: userId,
            authenticationManager: authenticationManager,
            tokenProvider: tokenProvider,
            onUserSelected: { [weak self] id in
                self?.openProfile(id)
            }
        )
    }
    
    func makeView(onUserSelected: @escaping (String) -> Void) -> some View {
        let model = FollowingListModel()
        let viewModel = FollowingListViewModel(
            model: model,
            userId: userId,
            onUserSelected: onUserSelected
        )
        return FollowingListView(viewModel: viewModel)
    }
    
    func openProfile(_ id: String) {
        nav.path.append(FollowingListRoute.profile(id))
    }
}

struct FollowingStackView: View {
    @ObservedObject var nav: FollowingNavPathStore
    let userId: String
    let authenticationManager: AuthManaging
    let tokenProvider: TokenProviding
    let onUserSelected: (String) -> Void
    
    var body: some View {
        NavigationStack(
            path: Binding(
                get: { nav.path },
                set: { nav.path = $0 }
            )
        ) {
            makeFollowingListView()
                .navigationDestination(for: FollowingListRoute.self) { route in
                    switch route {
                    case .profile(let id):
                        ProfileCoordinator(
                            userId: id,
                            authenticationManager: authenticationManager,
                            tokenProvider: tokenProvider
                        ).start()
                    }
                }
        }
    }
    
    private func makeFollowingListView() -> some View {
        let model = FollowingListModel()
        let viewModel = FollowingListViewModel(
            model: model,
            userId: userId,
            onUserSelected: onUserSelected
        )
        return FollowingListView(viewModel: viewModel)
    }
}
