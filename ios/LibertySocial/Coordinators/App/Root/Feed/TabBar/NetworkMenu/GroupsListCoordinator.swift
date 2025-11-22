
import SwiftUI
import Combine

enum NextGroupView {
    case groupsList
    case group(String)
    case createGroup
    case suggestedGroups
    case groupInvite(String)
    case aboutGroup(String)
}

@MainActor
final class GroupsListCoordinator {
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding
    private let groupService: GroupSession
    private let groupInviteService: GroupInviteSession
    private var currentViewModel: [GroupsListViewModel] = []
    private var childCoordinators: [Any] = []

    init(authManager: AuthManaging,
         tokenProvider: TokenProviding,
         groupService: GroupSession,
         groupInviteService: GroupInviteSession
    ) {
        self.authManager = authManager
        self.tokenProvider = tokenProvider
        self.groupService = groupService
        self.groupInviteService = groupInviteService
    }
    
    func start(nextView: NextGroupView = .groupsList,
               groupId: String? = nil) -> some View
    {
        switch nextView {
        case .groupsList:
            return startGroupsListView()
        case .createGroup:
            return startCreateGroupCoordinator()
        case .suggestedGroups:
            return startSuggestedGroupsCoordinator()
        case .group(let groupId):
            return startGroupRoomCoordinator(groupId: groupId)
        case .groupInvite(let groupId):
            return startGroupInviteCoordinator(groupId: groupId)
        case .aboutGroup(let groupId):
            return startAboutGroupCoordinator(groupId: groupId)
        }
    }
    
    func startGroupsListView() -> AnyView {
        let model = GroupsListModel(
            TokenProvider: tokenProvider,
            AuthManagerBadName: authManager
        )
        let viewModel = GroupsListViewModel(
            model: model,
            AuthManagerBadName: authManager,
            groupService: groupService
        )
        if currentViewModel.count > 0 {
            currentViewModel.removeAll()
        }
        currentViewModel.append(viewModel)
        viewModel.presentCreateGroupView = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .createGroup))
        }
        viewModel.presentSuggestedGroupsView = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .suggestedGroups))
        }
        viewModel.presentGroupView = { [weak self] groupId in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .group(groupId)))
        }
        viewModel.presentAboutGroupView = { [weak self] groupId in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .aboutGroup(groupId)))
        }
        viewModel.presentGroupInviteView = { [weak self] groupId in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .groupInvite(groupId)))
        }
        viewModel.onSuggestedGroupsViewFinish = { [weak self] in
            self?.removeSuggestedGroupsCoordinator()
        }
        viewModel.handleGroupsListViewDismiss = { [weak self] in
            guard let self = self else { return }
            self.onFinish()
        }
        let groupsListView = GroupsListView(viewModel: viewModel)
        return AnyView(groupsListView)
    }
    
    func removeSuggestedGroupsCoordinator() {
        childCoordinators.removeAll { coordinator in
            coordinator is SuggestedGroupsCoordinator
        }
    }
    
    func onFinish() {
        childCoordinators.removeAll()
        currentViewModel.removeAll()
    }
    
    func startCreateGroupCoordinator() -> AnyView {
        let coordinator = CreateGroupCoordinator(
            tokenProvider: tokenProvider,
            authManager: authManager,
            groupService: groupService,
            groupInviteService: groupInviteService
        )
        coordinator.onFinish = { [weak self] groupId in
            self?.currentViewModel.first?.showGroupInviteView(groupId: groupId)
        }
        return AnyView(coordinator.start())
    }
    
    func startSuggestedGroupsCoordinator() -> AnyView {
        let coordinator = SuggestedGroupsCoordinator(
            TokenProvider: tokenProvider,
            AuthManagerBadName: authManager
        )
        coordinator.onFinish = { [weak self] in
            guard let self = self else { return }
            self.currentViewModel.first?.hideSuggestedGroupsView()
        }
        coordinator.DisplayAboutGroupView = { [weak self] groupId in
            guard let self = self else { return }
            self.currentViewModel.first?.showAboutGroupView(groupId: groupId)
        }
        childCoordinators.append(coordinator)
        return AnyView(coordinator.start())
    }
    
    func startGroupRoomCoordinator(groupId: String) -> AnyView {
        let coordinator = GroupRoomCoordinator(
            groupId: groupId,
            TokenProvider: tokenProvider,
            AuthManagerBadName: authManager,
            groupService: groupService
        )
        coordinator.onFinish = { [weak self] in
            guard let self = self else { return }
            self.currentViewModel.first?.hideGroupRoomView()
            self.removeGroupRoomCoordinator()
        }
        childCoordinators.append(coordinator)
        return AnyView(coordinator.start())
    }
    
    func removeGroupRoomCoordinator() {
        childCoordinators.removeAll { coordinator in
            coordinator is GroupRoomCoordinator
        }
    }
    
    func startGroupInviteCoordinator(groupId: String) -> AnyView {
        // Add dismissal onFinish
        let coordinator = GroupInviteCoordinator(
            groupId: groupId,
            tokenProvider: tokenProvider,
            groupService: groupService,
            groupInviteService: groupInviteService
        )
        return AnyView(coordinator.start())
    }
    
    func startAboutGroupCoordinator(groupId: String) -> AnyView {
        let coordinator = AboutGroupCoordinator(
            groupId: groupId,
            groupService: groupService
        )
        return AnyView(coordinator.start())
    }
}
