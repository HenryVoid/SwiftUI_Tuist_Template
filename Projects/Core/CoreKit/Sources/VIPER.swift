import Foundation

// MARK: - VIPER Architecture

/// VIPER View 프로토콜
public protocol VIPERViewProtocol: AnyObject {
    // UI 업데이트 메서드
}

/// VIPER Interactor 프로토콜
public protocol VIPERInteractorProtocol: AnyObject {
    // 비즈니스 로직
}

/// VIPER Presenter 프로토콜
public protocol VIPERPresenterProtocol: AnyObject {
    // 프레젠테이션 로직
}

/// VIPER Entity 프로토콜
public protocol VIPEREntityProtocol {
    // 데이터 모델
}

/// VIPER Router 프로토콜
public protocol VIPERRouterProtocol: AnyObject {
    // 네비게이션 로직
}

/// VIPER Module Builder
public protocol VIPERModuleBuilder {
    associatedtype View: VIPERViewProtocol
    static func build() -> View
}

