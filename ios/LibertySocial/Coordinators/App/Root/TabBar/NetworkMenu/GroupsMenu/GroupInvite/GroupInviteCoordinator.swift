
import SwiftUI
import Combine

final class GroupInviteCoordinator {
    
    private let groupId: String
    private var cancellables = Set<AnyCancellable>()
    
    init(groupId: String) {
        self.groupId = groupId
    }
    
    func start() -> some View {
        let model = GroupInviteModel()
        let viewModel = GroupInviteViewModel(model: model, groupId: groupId)
        
        return GroupInviteViewWrapper(viewModel: viewModel, coordinator: self)
    }
    
    
    @MainActor
    func observeViewModel(_ viewModel: GroupInviteViewModel, dismiss: @escaping () -> Void) {
        viewModel.didFinishSuccessfully
            .sink { _ in
                dismiss()
            }
            .store(in: &cancellables)
    }
}


private struct GroupInviteViewWrapper: View {
    @StateObject private var viewModel: GroupInviteViewModel
    @Environment(\.dismiss) private var dismiss
    
    let coordinator: GroupInviteCoordinator
    
    init(viewModel: GroupInviteViewModel, coordinator: GroupInviteCoordinator) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.coordinator = coordinator
    }
    
    var body: some View {
        GroupInviteView(viewModel: viewModel)
            .onAppear {
                coordinator.observeViewModel(viewModel) {
                    dismiss()
                }
            }
    }
}
