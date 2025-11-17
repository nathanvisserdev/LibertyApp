
import Foundation
import Combine
import SwiftUI

@MainActor
final class NetworkMenuViewModel: ObservableObject {
    private let model: NetworkMenuModel
    private let authManager: AuthManaging
    
    @Published var isShowingConnections: Bool = false
    @Published var isShowingGroupsMenu: Bool = false
    @Published var isShowingSubnetMenu: Bool = false
    
    var makeConnectionsView: (() -> AnyView)?
    var makeGroupsMenuView: (() -> AnyView)?
    var makeSubnetMenuView: (() -> AnyView)?
    var onNavigate: ((NextNetworkView) -> Void)?
    
    init(
        model: NetworkMenuModel = NetworkMenuModel(),
        authManager: AuthManaging = AuthManager.shared
    ) {
        self.model = model
        self.authManager = authManager
    }
    
    func showConnectionsView() {
        isShowingConnections = true
    }
    
    func hideConnectionsView() {
        isShowingConnections = false
    }
    
    func showGroupsMenuView() {
        isShowingGroupsMenu = true
    }
    
    func hideGroupsMenuView() {
        isShowingGroupsMenu = false
    }
    
    func showSubnetMenuView() {
        isShowingSubnetMenu = true
    }
    
    func hideSubnetMenuView() {
        isShowingSubnetMenu = false
    }
}
