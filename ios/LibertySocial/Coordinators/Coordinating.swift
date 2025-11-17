import Foundation
import SwiftUI

protocol Coordinator: AnyObject {
    func start() -> AnyView
}

protocol ParentCoordinator: Coordinator {
    var childCoordinators: [ChildCoordinator] { get set }
    func addChild(coordinator: ChildCoordinator)
    func removeChild(coordinator: ChildCoordinator)
}

protocol ChildCoordinator: Coordinator {
    var onFinish: (() -> Void)? { get set }
}
