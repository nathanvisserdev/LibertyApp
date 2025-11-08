
import SwiftUI
import Combine

@MainActor
final class GroupsMenuCoordinator: ObservableObject {
    
    @Published var isShowingGroupsMenu: Bool = false
    @Published var showCreateGroup: Bool = false
    @Published var showSuggestedGroups: Bool = false
    @Published var selectedGroup: UserGroup? = nil
    
    private let authenticationManager: AuthManaging
    private let tokenProvider: TokenProviding
    
    private lazy var createGroupCoordinator: CreateGroupCoordinator = {
        CreateGroupCoordinator(
            tokenProvider: tokenProvider,
            authManager: authenticationManager
        )
    }()
    
    private lazy var suggestedGroupsCoordinator: SuggestedGroupsCoordinator = {
        SuggestedGroupsCoordinator(
            TokenProvider: tokenProvider,
            AuthManagerBadName: authenticationManager
        )
    }()
    
    private lazy var groupCoordinatorFactory: (UserGroup) -> GroupCoordinator = { [unowned self] group in
        GroupCoordinator(
            group: group,
            TokenProvider: self.tokenProvider,
            AuthManagerBadName: self.authenticationManager
        )
    }

    init(authenticationManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.authenticationManager = authenticationManager
        self.tokenProvider = tokenProvider
    }
    
    
    func showGroupsMenu() {
        isShowingGroupsMenu = true
    }
    
    func presentCreateGroup() {
        showCreateGroup = true
    }
    
    func presentSuggestedGroups() {
        showSuggestedGroups = true
    }
    
    func presentGroup(_ group: UserGroup) {
        selectedGroup = group
    }

    func makeView() -> some View {
        let viewModel = GroupsMenuViewModel(coordinator: self)
        return GroupsMenuView(viewModel: viewModel, coordinator: self)
    }
    
    
    func makeCreateGroupView() -> some View {
        return createGroupCoordinator.start(onDismiss: { [weak self] in
            self?.showCreateGroup = false
        })
    }
    
    func makeSuggestedGroupsView() -> some View {
        return suggestedGroupsCoordinator.start(
            onDismiss: { [weak self] in
                self?.showSuggestedGroups = false
            },
            onSelect: { [weak self] group in
                self?.showSuggestedGroups = false
                self?.presentGroup(group)
            }
        )
    }
    
    func makeGroupView(for group: UserGroup) -> some View {
        return groupCoordinatorFactory(group).start(onClose: { [weak self] in
            self?.selectedGroup = nil
        })
    }
}
