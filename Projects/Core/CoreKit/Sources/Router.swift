import Foundation
import SwiftUI

// MARK: - Router Pattern

/// 라우트 프로토콜
public protocol Route: Hashable, Sendable {
    var path: String { get }
}

/// Router 프로토콜
@MainActor
public protocol Router: ObservableObject {
    associatedtype RouteType: Route
    
    var path: NavigationPath { get set }
    func navigate(to route: RouteType)
    func pop()
    func popToRoot()
}

/// 기본 Router 구현
@MainActor
open class BasicRouter<RouteType: Route>: Router, ObservableObject {
    @Published public var path: NavigationPath
    
    public init() {
        self.path = NavigationPath()
    }
    
    public func navigate(to route: RouteType) {
        path.append(route)
    }
    
    public func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    public func popToRoot() {
        path = NavigationPath()
    }
}

