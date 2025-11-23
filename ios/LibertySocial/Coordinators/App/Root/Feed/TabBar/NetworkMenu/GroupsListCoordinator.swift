
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
        viewModel.presentCreateGroupView = { [weak self] in
            guard let self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .createGroup))
        }
        viewModel.presentSuggestedGroupsView = { [weak self] in
            guard let self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .suggestedGroups))
        }
        viewModel.presentGroupView = { [weak self] groupId in
            guard let self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .group(groupId)))
        }
        viewModel.presentAboutGroupView = { [weak self] groupId in
            guard let self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .aboutGroup(groupId)))
        }
        viewModel.presentGroupInviteView = { [weak self] groupId in
            guard let self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .groupInvite(groupId)))
        }
        viewModel.onFinish = { [weak self] in
            guard let self else { return }
            self.handleCleanup()
        }
        currentViewModel.append(viewModel)
        let groupsListView = GroupsListView(viewModel: viewModel)
        return AnyView(groupsListView)
    }
    
    func handleCleanup() {
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
        coordinator.presentNextView = { [weak self] groupId in
            guard let self else { return }
            self.currentViewModel.first?.showGroupInviteView(groupId: groupId)
        }
        coordinator.dismissView = { [weak self] in
            guard let self else { return }
            self.currentViewModel.first?.hideCreateGroupView()
        }
        coordinator.onFinish = { [weak self] in
            guard let self else { return }
            self.childCoordinators.removeAll { coordinator in
                coordinator is CreateGroupCoordinator
            }
        }
        childCoordinators.append(coordinator)
        return AnyView(coordinator.start())
    }
    
    func startSuggestedGroupsCoordinator() -> AnyView {
        let coordinator = SuggestedGroupsCoordinator(
            TokenProvider: tokenProvider,
            AuthManagerBadName: authManager
        )
        coordinator.presentNextView = { [weak self] groupId in
            guard let self else { return }
            self.currentViewModel.first?.showAboutGroupView(groupId: groupId)
        }
        coordinator.dismissView = { [weak self] in
            guard let self else { return }
            self.currentViewModel.first?.hideSuggestedGroupsView()
        }
        coordinator.onFinish = { [weak self] in
            guard let self else { return }
            self.childCoordinators.removeAll { coordinator in
                coordinator is SuggestedGroupsCoordinator
            }
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
        coordinator.dismissView = { [weak self] in
            guard let self else { return }
            self.currentViewModel.first?.hideGroupRoomView()
        }
        coordinator.onFinish = { [weak self] in
            guard let self else { return }
            childCoordinators.removeAll() { coordinator in
                coordinator is GroupRoomCoordinator
            }
        }
        childCoordinators.append(coordinator)
        return AnyView(coordinator.start())
    }
    
    func startGroupInviteCoordinator(groupId: String) -> AnyView {
        let coordinator = GroupInviteCoordinator(
            groupId: groupId,
            tokenProvider: tokenProvider,
            groupService: groupService,
            groupInviteService: groupInviteService
        )
        coordinator.dismissView = { [weak self] in
            guard let self else { return }
            self.currentViewModel.first?.hideGroupInviteView()
        }
        coordinator.onFinish = { [weak self] in
            guard let self else { return }
            childCoordinators.removeAll() { coordinator in
                coordinator is GroupInviteCoordinator
            }
        }
        childCoordinators.append(coordinator)
        return AnyView(coordinator.start())
    }
    
    func startAboutGroupCoordinator(groupId: String) -> AnyView {
        let coordinator = AboutGroupCoordinator(
            groupId: groupId,
            groupService: groupService
        )
        coordinator.dismissView = { [weak self] in
            guard let self else { return }
            self.currentViewModel.first?.hideAboutGroupView()
        }
        coordinator.onFinish = { [weak self] in
            guard let self else { return }
            childCoordinators.removeAll() { coordinator in
                coordinator is AboutGroupCoordinator
            }
        }
        childCoordinators.append(coordinator)
        return AnyView(coordinator.start())
    }
}
