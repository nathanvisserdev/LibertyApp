
import SwiftUI

final class AboutGroupCoordinator {
    private let groupId: String
    private let groupService: GroupSession
    
    init(groupId: String,
         groupService: GroupSession) {
        self.groupId = groupId
        self.groupService = groupService
    }
    
    func start() -> some View {
        let model = AboutGroupModel(groupService: groupService)
        let viewModel = AboutGroupViewModel(groupId: groupId, model: model)
        return AboutGroupView(viewModel: viewModel)
    }
}
