
import SwiftUI

final class GroupRoomCoordinator {
    private let TokenProvider: TokenProviding
    private let AuthManagerBadName: AuthManaging
    private let groupService: GroupSession
    private let groupId: String
    var onFinish: (() -> Void)?
    
    init(groupId: String,
         TokenProvider: TokenProviding,
         AuthManagerBadName: AuthManaging,
         groupService: GroupSession) {
        self.groupId = groupId
        self.TokenProvider = TokenProvider
        self.AuthManagerBadName = AuthManagerBadName
        self.groupService = groupService
    }
    
    func start() -> some View {
        let model = GroupRoomModel(
            TokenProvider: TokenProvider,
            AuthManagerBadName: AuthManagerBadName,
            groupService: groupService
        )
        let viewModel = GroupRoomViewModel(
            groupId: groupId,
            model: model
        )
        viewModel.handleDoneTap = { [weak self] in
            self?.onFinish?()
        }
        return GroupRoomView(viewModel: viewModel)
    }
}
