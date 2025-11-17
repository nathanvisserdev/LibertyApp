
import SwiftUI
import Combine

enum NextGroupView {
    case groupsList
    case group(UserGroup)
    case createGroup
    case suggestedGroups
}

@MainActor
final class GroupsListCoordinator {
    var onFinished: (() -> Void)?
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding
    private let groupService: GroupSession
    private let groupsListView: GroupsListView
    private let groupsListViewModel: GroupsListViewModel
    private let createGroupCoordinator: CreateGroupCoordinator
    private let suggestedGroupsCoordinator: SuggestedGroupsCoordinator
    private var groupCoordinator: GroupCoordinator?

    init(authManager: AuthManaging,
         tokenProvider: TokenProviding,
         groupService: GroupSession) {
        self.authManager = authManager
        self.tokenProvider = tokenProvider
        self.groupService = groupService
        
        let groupsListModel = GroupsListModel(
            TokenProvider: tokenProvider,
            AuthManagerBadName: authManager
        )
        let groupsListViewModel = GroupsListViewModel(
            model: groupsListModel,
            AuthManagerBadName: authManager,
            groupService: groupService
        )
        self.groupsListViewModel = groupsListViewModel
        self.groupsListView = GroupsListView(viewModel: groupsListViewModel)
        
        self.createGroupCoordinator = CreateGroupCoordinator(
            tokenProvider: tokenProvider,
            authManager: authManager,
            groupsListViewModel: groupsListViewModel
        )
        
        self.suggestedGroupsCoordinator = SuggestedGroupsCoordinator(
            TokenProvider: tokenProvider,
            AuthManagerBadName: authManager,
            groupsListViewModel: groupsListViewModel
        )
        
        groupsListViewModel.onNavigate = { [weak self] nextView in
            self?.start(nextView: nextView)
        }
        
        groupsListViewModel.makeCreateGroupView = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .createGroup))
        }
        
        groupsListViewModel.makeGroupView = { [weak self] group in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .group(group)))
        }
        
        groupsListViewModel.makeSuggestedGroupsView = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .suggestedGroups))
        }
    }

    func start(nextView: NextGroupView) -> some View {
        switch nextView {
        case .groupsList:
            return AnyView(groupsListView)
        case .group(let group):
            groupCoordinator = GroupCoordinator(
                group: group,
                TokenProvider: tokenProvider,
                AuthManagerBadName: authManager,
                groupsListViewModel: groupsListViewModel
            )
            return AnyView(groupCoordinator!.start())
        case .createGroup:
            return AnyView(createGroupCoordinator.start())
        case .suggestedGroups:
            return AnyView(suggestedGroupsCoordinator.start())
        }
    }
}
