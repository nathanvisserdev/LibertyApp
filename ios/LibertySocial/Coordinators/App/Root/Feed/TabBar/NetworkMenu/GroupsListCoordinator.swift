
import SwiftUI
import Combine

enum NextGroupView {
    case groupsList
    case group(UserGroup)
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
    private weak var currentViewModel: GroupsListViewModel?
    private var childCoordinators: [Any] = []

    init(authManager: AuthManaging,
         tokenProvider: TokenProviding,
         groupService: GroupSession,
         groupInviteService: GroupInviteSession) {
        self.authManager = authManager
        self.tokenProvider = tokenProvider
        self.groupService = groupService
        self.groupInviteService = groupInviteService
    }

    func presentViewFromChild(nextView: NextGroupView, groupId: String) {
        _ = start(nextView: nextView, groupId: groupId)
    }
    
    func start(nextView: NextGroupView = .groupsList, groupId: String? = nil) -> some View {
        switch nextView {
        case .groupsList:
            return startGroupsListView()
        case .createGroup:
            return startCreateGroupCoordinator()
        case .suggestedGroups:
            return startSuggestedGroupsCoordinator()
        case .group(let group):
            return startGroupRoomCoordinator(group: group)
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
        currentViewModel = viewModel
        viewModel.presentCreateGroupView = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .createGroup))
        }
        viewModel.presentGroupView = { [weak self] group in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .group(group)))
        }
        viewModel.presentSuggestedGroupsView = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .suggestedGroups))
        }
        viewModel.presentGroupInviteView = { [weak self] groupId in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .groupInvite(groupId)))
        }
        viewModel.presentAboutGroupView = { [weak self] groupId in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .aboutGroup(groupId)))
        }
        let groupsListView = GroupsListView(viewModel: viewModel)
        return AnyView(groupsListView)
    }
    
    func startCreateGroupCoordinator() -> AnyView {
        let createGroupCoordinator = CreateGroupCoordinator(
            tokenProvider: tokenProvider,
            authManager: authManager,
            groupService: groupService,
            groupInviteService: groupInviteService
        )
        createGroupCoordinator.onFinish = { [weak self] (groupId: String) in
            guard let self = self else { return }
            self.dismissCreateGroupView()
            self.currentViewModel?.signalToPresentGroupInviteView(groupId: groupId)
        }
        return AnyView(createGroupCoordinator.start())
    }
    
    func dismissCreateGroupView() {
        currentViewModel?.hideCreateGroupView()
    }
    
    func dismissSuggestedGroupsView() {
        currentViewModel?.hideSuggestedGroupsView()
    }
    
    func startSuggestedGroupsCoordinator() -> AnyView {
        let model = GroupsListModel(
            TokenProvider: tokenProvider,
            AuthManagerBadName: authManager
        )
        let viewModel = GroupsListViewModel(
            model: model,
            AuthManagerBadName: authManager,
            groupService: groupService
        )
        let coordinator = SuggestedGroupsCoordinator(
            TokenProvider: tokenProvider,
            AuthManagerBadName: authManager
        )
        coordinator.handleGroupTapped = { [weak self] (groupId: String) in
            guard let self = self else { return }
            self.dismissSuggestedGroupsView()
            self.currentViewModel?.publishGroupTapped(groupId: groupId)
        }
        childCoordinators.append(coordinator)
        return AnyView(coordinator.start())
    }
    
    func startGroupRoomCoordinator(group: UserGroup) -> AnyView {
        let model = GroupRoomModel(
            TokenProvider: tokenProvider,
            AuthManagerBadName: authManager,
        )
        let viewModel = GroupRoomViewModel(group: group, model: model)
        let assemblyRoomCoordinator = GroupRoomCoordinator(
            group: group,
            TokenProvider: tokenProvider,
            AuthManagerBadName: authManager
        )
        return AnyView(assemblyRoomCoordinator.start())
    }
    
    func startGroupInviteCoordinator(groupId: String) -> AnyView {
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
