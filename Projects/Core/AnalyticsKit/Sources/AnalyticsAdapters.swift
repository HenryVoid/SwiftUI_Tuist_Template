import Foundation

/// Firebase Analytics 어댑터 (예시)
public actor FirebaseAnalyticsAdapter: AnalyticsProvider {
    // Firebase SDK를 실제로 통합할 때 사용
    // import FirebaseAnalytics
    
    public init() {}
    
    public func logEvent(_ event: AnalyticsEvent) async {
        // Firebase.Analytics.logEvent(event.name, parameters: event.parameters)
        // 실제 Firebase SDK 호출
        print("🔥 [Firebase] Event: \(event.name)")
    }
    
    public func setUserProperty(key: String, value: String) async {
        // Firebase.Analytics.setUserProperty(value, forName: key)
        print("🔥 [Firebase] User Property: \(key) = \(value)")
    }
    
    public func setUserId(_ userId: String?) async {
        // Firebase.Analytics.setUserID(userId)
        print("🔥 [Firebase] User ID: \(userId ?? "nil")")
    }
}

/// Amplitude Analytics 어댑터 (예시)
public actor AmplitudeAnalyticsAdapter: AnalyticsProvider {
    // Amplitude SDK를 실제로 통합할 때 사용
    
    public init() {}
    
    public func logEvent(_ event: AnalyticsEvent) async {
        // Amplitude.instance().logEvent(event.name, withEventProperties: event.parameters)
        print("📈 [Amplitude] Event: \(event.name)")
    }
    
    public func setUserProperty(key: String, value: String) async {
        // Amplitude.instance().setUserProperties([key: value])
        print("📈 [Amplitude] User Property: \(key) = \(value)")
    }
    
    public func setUserId(_ userId: String?) async {
        // Amplitude.instance().setUserId(userId)
        print("📈 [Amplitude] User ID: \(userId ?? "nil")")
    }
}

