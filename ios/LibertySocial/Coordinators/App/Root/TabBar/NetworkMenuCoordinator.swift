
import SwiftUI
import Combine

enum NextNetworkView {
    case networkMenu
    case connections
    case groupsList
    case subnetList
}

@MainActor
final class NetworkMenuCoordinator {
    var onFinished: (() -> Void)?
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding
    private let groupService: GroupSession
    private let subnetService: SubnetSession
    private let networkMenuView: NetworkMenuView
    private let networkMenuViewModel: NetworkMenuViewModel
    private let connectionsListCoordinator: ConnectionsListCoordinator
    private let groupsListCoordinator: GroupsListCoordinator
    private let subnetMenuCoordinator: SubnetListCoordinator

    init(authManager: AuthManaging,
         tokenProvider: TokenProviding,
         groupService: GroupSession,
         subnetService: SubnetSession) {
        self.authManager = authManager
        self.tokenProvider = tokenProvider
        self.groupService = groupService
        self.subnetService = subnetService
        
        let networkMenuModel = NetworkMenuModel()
        let networkMenuViewModel = NetworkMenuViewModel(
            model: networkMenuModel,
            authManager: authManager
        )
        self.networkMenuViewModel = networkMenuViewModel
        self.networkMenuView = NetworkMenuView(viewModel: networkMenuViewModel)
        
        self.connectionsListCoordinator = ConnectionsListCoordinator(
            authManager: authManager,
            tokenProvider: tokenProvider,
            networkMenuViewModel: networkMenuViewModel
        )
        
        self.groupsListCoordinator = GroupsListCoordinator(
            authManager: authManager,
            tokenProvider: tokenProvider,
            groupService: groupService
        )
        
        self.subnetMenuCoordinator = SubnetListCoordinator(
            authManager: authManager,
            tokenProvider: tokenProvider,
            subnetService: subnetService
        )
        
        networkMenuViewModel.onNavigate = { [weak self] nextView in
            self?.start(nextView: nextView)
        }
        
        networkMenuViewModel.makeConnectionsView = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .connections))
        }
        
        networkMenuViewModel.makeGroupsMenuView = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .groupsList))
        }
        
        networkMenuViewModel.makeSubnetMenuView = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .subnetList))
        }
    }

    func start(nextView: NextNetworkView) -> some View {
        switch nextView {
        case .networkMenu:
            return AnyView(networkMenuView)
        case .connections:
            return AnyView(connectionsListCoordinator.start())
        case .groupsList:
            return AnyView(groupsListCoordinator.start(nextView: .groupsList))
        case .subnetList:
            return AnyView(subnetMenuCoordinator.start(nextView: .subnetList))
        }
    }
}
