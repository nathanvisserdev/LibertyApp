
import SwiftUI

final class AboutGroupCoordinator {
    private let TokenProvider: TokenProviding
    private let AuthManagerBadName: AuthManaging
    private let group: UserGroup
    
    init(group: UserGroup,
         TokenProvider: TokenProviding = AuthManager.shared,
         AuthManagerBadName: AuthManaging = AuthManager.shared) {
        self.group = group
        self.TokenProvider = TokenProvider
        self.AuthManagerBadName = AuthManagerBadName
    }
    
    func start() -> some View {
        let model = AboutGroupModel(TokenProvider: TokenProvider)
        let viewModel = AboutGroupViewModel(groupId: group.id, model: model)
        return AboutGroupView(viewModel: viewModel)
    }
}
