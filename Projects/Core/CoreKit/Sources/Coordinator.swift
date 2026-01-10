import Foundation

// MARK: - Coordinator Pattern

/// Coordinator 프로토콜
public protocol Coordinator: AnyObject {
    var childCoordinators: [any Coordinator] { get set }
    func start()
    func coordinate(to coordinator: any Coordinator)
    func removeChild(_ coordinator: any Coordinator)
}

public extension Coordinator {
    func coordinate(to coordinator: any Coordinator) {
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    func removeChild(_ coordinator: any Coordinator) {
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

