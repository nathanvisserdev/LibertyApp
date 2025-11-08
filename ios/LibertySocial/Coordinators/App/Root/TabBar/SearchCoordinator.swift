
import SwiftUI
import Combine

@MainActor
final class SearchCoordinator: ObservableObject {
    @Published var isShowingSearch: Bool = false
    
    private var selectedUserId: String?
    private var profileCoordinator: ProfileCoordinator?
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding

    init(authManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.authManager = authManager
        self.tokenProvider = tokenProvider
    }
    
    func showSearch() {
        isShowingSearch = true
    }
    
    func showProfile(for userId: String) {
        selectedUserId = userId
        profileCoordinator = ProfileCoordinator(
            userId: userId,
            authManager: authManager,
            tokenProvider: tokenProvider
        )
    }

    func makeView() -> some View {
        let model = SearchModel()
        let viewModel = SearchViewModel(
            model: model,
            onUserSelected: { [weak self] userId in
                self?.showProfile(for: userId)
            }
        )
        
        viewModel.onShowProfile = { [weak self] in
            guard let self = self,
                  let coordinator = self.profileCoordinator else {
                return AnyView(EmptyView())
            }
            return AnyView(coordinator.start())
        }
        
        return SearchView(viewModel: viewModel)
    }
}
