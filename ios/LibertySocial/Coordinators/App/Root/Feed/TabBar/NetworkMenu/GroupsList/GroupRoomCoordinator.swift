
import SwiftUI

final class GroupRoomCoordinator {
    
    private let TokenProvider: TokenProviding
    private let AuthManagerBadName: AuthManaging
    private let group: UserGroup
    
    var onClose: (() -> Void)?
    
    init(group: UserGroup,
         TokenProvider: TokenProviding,
         AuthManagerBadName: AuthManaging) {
        self.group = group
        self.TokenProvider = TokenProvider
        self.AuthManagerBadName = AuthManagerBadName
    }
    
    func start() -> some View {
        let model = GroupRoomModel(TokenProvider: TokenProvider, AuthManagerBadName: AuthManagerBadName)
        let viewModel = GroupRoomViewModel(group: group, model: model)
        
        viewModel.onClose = { [weak self] in
            self?.onClose?()
        }
        return GroupRoomView(group: group, viewModel: viewModel)
    }
}
