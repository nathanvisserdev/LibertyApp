
import Foundation
import Combine
import SwiftUI

@MainActor
final class NetworkMenuViewModel: ObservableObject {
    private let model: NetworkMenuModel
    private let authManager: AuthManaging
    private let onConnectionsTapped: () -> Void
    private let onGroupsMenuTapped: () -> Void
    private let onSubnetMenuTapped: () -> Void
    
    var onShowConnections: () -> AnyView = { AnyView(EmptyView()) }
    var onShowGroupsMenu: () -> AnyView = { AnyView(EmptyView()) }
    var onShowSubnetMenu: () -> AnyView = { AnyView(EmptyView()) }
    
    @Published var isShowingConnections: Bool = false
    @Published var isShowingGroupsMenu: Bool = false
    @Published var isShowingSubnetMenu: Bool = false
    
    init(
        model: NetworkMenuModel = NetworkMenuModel(),
        authManager: AuthManaging = AuthManager.shared,
        onConnectionsTapped: @escaping () -> Void,
        onGroupsMenuTapped: @escaping () -> Void,
        onSubnetMenuTapped: @escaping () -> Void
    ) {
        self.model = model
        self.authManager = authManager
        self.onConnectionsTapped = onConnectionsTapped
        self.onGroupsMenuTapped = onGroupsMenuTapped
        self.onSubnetMenuTapped = onSubnetMenuTapped
    }
    
    func showConnectionsView() {
        isShowingConnections = true
        onConnectionsTapped()
    }
    
    func showGroupsMenuView() {
        isShowingGroupsMenu = true
        onGroupsMenuTapped()
    }
    
    func showSubnetMenuView() {
        isShowingSubnetMenu = true
        onSubnetMenuTapped()
    }
}
