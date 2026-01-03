import Foundation

/// Analytics 이벤트
public struct AnalyticsEvent: Sendable {
    public let name: String
    public let parameters: [String: Any]?
    public let timestamp: Date
    
    public init(name: String, parameters: [String: Any]? = nil, timestamp: Date = Date()) {
        self.name = name
        self.parameters = parameters
        self.timestamp = timestamp
    }
}

/// Analytics 제공자 프로토콜
public protocol AnalyticsProvider: Sendable {
    func logEvent(_ event: AnalyticsEvent) async
    func setUserProperty(key: String, value: String) async
    func setUserId(_ userId: String?) async
}

