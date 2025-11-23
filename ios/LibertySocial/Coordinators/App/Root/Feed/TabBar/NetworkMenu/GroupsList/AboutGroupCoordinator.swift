
import SwiftUI

final class AboutGroupCoordinator {
    private let groupId: String
    private let groupService: GroupSession
    private var viewModel: [AboutGroupViewModel] = []
    var dismissView: (() -> Void)?
    var onFinish: (() -> Void)?
    
    init(groupId: String,
         groupService: GroupSession
    ) {
        self.groupId = groupId
        self.groupService = groupService
    }
    
    func start() -> some View {
        let model = AboutGroupModel(groupService: groupService)
        let viewModel = AboutGroupViewModel(groupId: groupId, model: model)
        viewModel.handleDoneTap = { [weak self] in
            guard let self else { return }
            dismissView?()
        }
        viewModel.handleDisappear = { [weak self] in
            guard let self else { return }
            self.viewModel.removeAll()
            onFinish?()
        }
        self.viewModel.append(viewModel)
        return AboutGroupView(viewModel: viewModel)
    }
}
