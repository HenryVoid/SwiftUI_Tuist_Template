import Foundation

/// 콘솔 Analytics 제공자 (디버그용)
public actor ConsoleAnalyticsProvider: AnalyticsProvider {
    private let isEnabled: Bool
    
    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    
    public func logEvent(_ event: AnalyticsEvent) async {
        guard isEnabled else { return }
        
        print("📊 [Analytics] Event: \(event.name)")
        if let parameters = event.parameters {
            print("   Parameters: \(parameters)")
        }
        print("   Timestamp: \(event.timestamp)")
    }
    
    public func setUserProperty(key: String, value: String) async {
        guard isEnabled else { return }
        print("👤 [Analytics] User Property: \(key) = \(value)")
    }
    
    public func setUserId(_ userId: String?) async {
        guard isEnabled else { return }
        if let userId = userId {
            print("👤 [Analytics] User ID: \(userId)")
        } else {
            print("👤 [Analytics] User ID cleared")
        }
    }
}

