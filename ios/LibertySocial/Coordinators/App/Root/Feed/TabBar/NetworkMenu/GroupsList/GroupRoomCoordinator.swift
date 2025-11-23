
import SwiftUI

final class GroupRoomCoordinator {
    private let TokenProvider: TokenProviding
    private let AuthManagerBadName: AuthManaging
    private let groupService: GroupSession
    private let groupId: String
    private var viewModel: [GroupRoomViewModel] = []
    var dismissView: (() -> Void)?
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
        return startGroupRoomView()
    }
    
    func startGroupRoomView() -> AnyView {
        let model = GroupRoomModel(
            TokenProvider: TokenProvider,
            AuthManagerBadName: AuthManagerBadName,
            groupService: groupService
        )
        let viewModel = GroupRoomViewModel(
            groupId: groupId,
            model: model
        )
        viewModel.onDoneTap = { [weak self] in
            guard let self = self else { return }
            self.dismissView?()
        }
        viewModel.onFinish = { [weak self] in
            guard let self = self else { return }
            self.viewModel.removeAll()
            self.onFinish?()
        }
        self.viewModel.append(viewModel)
        let view = GroupRoomView(viewModel: viewModel)
        return AnyView(view)
    }
}
