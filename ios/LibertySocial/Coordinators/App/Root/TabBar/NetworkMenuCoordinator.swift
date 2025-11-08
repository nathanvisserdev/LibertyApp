
import SwiftUI
import Combine

@MainActor
final class NetworkMenuCoordinator: ObservableObject {
    @Published var isShowingNetworkMenu: Bool = false
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding
    private let connectionsListCoordinator: ConnectionsListCoordinator
    private let groupsMenuCoordinator: GroupsMenuCoordinator
    private let subnetMenuCoordinator: SubnetListCoordinator

    init(authManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.authManager = authManager
        self.tokenProvider = tokenProvider
        self.connectionsListCoordinator = ConnectionsListCoordinator(
            authManager: authManager,
            tokenProvider: tokenProvider
        )
        self.groupsMenuCoordinator = GroupsMenuCoordinator(
            authManager: authManager,
            tokenProvider: tokenProvider
        )
        self.subnetMenuCoordinator = SubnetListCoordinator(
            authManager: authManager,
            tokenProvider: tokenProvider
        )
    }
    
    func showNetworkMenu() {
        isShowingNetworkMenu = true
    }
    
    private func showConnections() {
        connectionsListCoordinator.showConnections()
    }
    
    private func showGroupsMenu() {
        groupsMenuCoordinator.showGroupsMenu()
    }
    
    private func showSubnetMenu() {
        subnetMenuCoordinator.showSubnetMenu()
    }
    
    func makeView() -> some View {
        let viewModel = NetworkMenuViewModel(
            onConnectionsTapped: { [weak self] in
                self?.showConnections()
            },
            onGroupsMenuTapped: { [weak self] in
                self?.showGroupsMenu()
            },
            onSubnetMenuTapped: { [weak self] in
                self?.showSubnetMenu()
            }
        )
        
        viewModel.onShowConnections = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.connectionsListCoordinator.makeView())
        }
        
        viewModel.onShowGroupsMenu = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.groupsMenuCoordinator.makeView())
        }
        
        viewModel.onShowSubnetMenu = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.subnetMenuCoordinator.makeView())
        }
        
        return NetworkMenuView(viewModel: viewModel)
    }
}
