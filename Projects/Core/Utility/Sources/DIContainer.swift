import Foundation

/// DI Container 프로토콜
public protocol DIContainer: Sendable {
    func register<T>(_ type: T.Type, factory: @Sendable @escaping () -> T)
    func resolve<T>(_ type: T.Type) -> T?
}

/// Manual DI Container 구현
public final class ManualDIContainer: DIContainer, @unchecked Sendable {
    public static let shared = ManualDIContainer()
    
    private var factories: [String: @Sendable () -> Any] = [:]
    private var singletons: [String: Any] = [:]
    private let lock = NSLock()
    
    private init() {}
    
    /// 서비스 등록 (Transient - 매번 새 인스턴스)
    public func register<T>(_ type: T.Type, factory: @Sendable @escaping () -> T) {
        let key = String(describing: type)
        lock.lock()
        factories[key] = factory
        lock.unlock()
    }
    
    /// 서비스 등록 (Singleton - 단일 인스턴스)
    public func registerSingleton<T>(_ type: T.Type, factory: @Sendable @escaping () -> T) {
        let key = String(describing: type)
        lock.lock()
        factories[key] = {
            if let singleton = self.singletons[key] as? T {
                return singleton
            }
            let instance = factory()
            self.singletons[key] = instance
            return instance
        }
        lock.unlock()
    }
    
    /// 서비스 해결
    public func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        lock.lock()
        defer { lock.unlock() }
        
        guard let factory = factories[key] else {
            return nil
        }
        
        return factory() as? T
    }
    
    /// 모든 등록 제거
    public func removeAll() {
        lock.lock()
        factories.removeAll()
        singletons.removeAll()
        lock.unlock()
    }
}

// MARK: - Property Wrapper

/// Dependency Injection Property Wrapper
@propertyWrapper
public struct Injected<T> {
    private let container: DIContainer
    
    public init(container: DIContainer = ManualDIContainer.shared) {
        self.container = container
    }
    
    public var wrappedValue: T {
        guard let resolved = container.resolve(T.self) else {
            fatalError("❌ Dependency \(T.self) not registered in DI Container")
        }
        return resolved
    }
}

// MARK: - Protocol-based DI Example

/// 사용 예시를 위한 프로토콜들
public protocol NetworkServiceProtocol: Sendable {
    func fetch() async throws -> String
}

public protocol CacheServiceProtocol: Sendable {
    func save(_ value: String) async throws
}

/// DI Container 설정 헬퍼
public extension ManualDIContainer {
    /// 기본 서비스 등록
    func registerDefaultServices() {
        // 실제 프로젝트에서는 여기에 서비스들을 등록
        // 예: registerSingleton(NetworkServiceProtocol.self) { NetworkService() }
    }
}

