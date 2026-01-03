import Foundation

// MARK: - Coordinator Pattern

/// Coordinator 프로토콜
public protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
    func coordinate(to coordinator: Coordinator)
    func removeChild(_ coordinator: Coordinator)
}

public extension Coordinator {
    func coordinate(to coordinator: Coordinator) {
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}

#if canImport(UIKit)
import UIKit

/// UIKit Coordinator
public protocol UIKitCoordinator: Coordinator {
    var navigationController: UINavigationController { get }
}
#endif

