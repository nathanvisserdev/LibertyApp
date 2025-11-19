
import SwiftUI
import Combine

enum NextGroupView {
    case groupsList
    case group(UserGroup)
    case createGroup
    case suggestedGroups
    case groupInvite(String)
}

@MainActor
final class GroupsListCoordinator {
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding
    private let groupService: GroupSession
    private let groupInviteService: GroupInviteSession

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
            return startAssemblyRoomCoordinator(group: group)
        case .groupInvite(let groupId):
            return startGroupInviteCoordinator(groupId: groupId)
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
        viewModel.makeCreateGroupView = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .createGroup))
        }
        viewModel.makeGroupView = { [weak self] group in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .group(group)))
        }
        viewModel.makeSuggestedGroupsView = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .suggestedGroups))
        }
        let groupsListView = GroupsListView(viewModel: viewModel)
        return AnyView(groupsListView)
    }
    
    func startCreateGroupCoordinator() -> AnyView {
        let model = GroupsListModel(
            TokenProvider: tokenProvider,
            AuthManagerBadName: authManager
        )
        let viewModel = GroupsListViewModel(
            model: model,
            AuthManagerBadName: authManager,
            groupService: groupService
        )
        let createGroupCoordinator = CreateGroupCoordinator(
            tokenProvider: tokenProvider,
            authManager: authManager,
            groupService: groupService,
            groupInviteService: groupInviteService
        )
        createGroupCoordinator.handlePresentGroupInviteView = { [weak self] groupId in
            self?.presentViewFromChild(nextView: .groupInvite(groupId), groupId: groupId)
        }
        createGroupCoordinator.onFinished = {
            viewModel.hideCreateGroupView()
        }
        createGroupCoordinator.onCancelled = {
            viewModel.hideCreateGroupView()
        }
        return AnyView(createGroupCoordinator.start(groupId: nil))
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
        coordinator.onDismiss = {
            viewModel.hideSuggestedGroupsView()
        }
        coordinator.onGroupSelected = { group in
            viewModel.hideSuggestedGroupsView()
            viewModel.showGroup(group)
        }
        return AnyView(coordinator.start())
    }
    
    func startAssemblyRoomCoordinator(group: UserGroup) -> AnyView {
        let model = AssemblyRoomModel(
            TokenProvider: tokenProvider,
            AuthManagerBadName: authManager,
        )
        let viewModel = AssemblyRoomViewModel(group: group, model: model)
        let assemblyRoomCoordinator = AssemblyRoomCoordinator(
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
}
