import Foundation

// MARK: - MVVM + Clean Architecture

/// Use Case 프로토콜
public protocol UseCase {
    associatedtype Request
    associatedtype Response
    
    func execute(request: Request) async throws -> Response
}

/// Repository 프로토콜
public protocol Repository: Sendable {
    // 서브클래스에서 구현
}

/// ViewModel 프로토콜
@MainActor
public protocol ViewModel: ObservableObject {
    associatedtype State
    associatedtype Action
    
    var state: State { get }
    func send(_ action: Action)
}

