import Foundation

/// Analytics 이벤트 큐 항목
struct QueuedEvent: Codable, Sendable {
    let event: SerializableEvent
    let timestamp: Date
}

/// 직렬화 가능한 이벤트
struct SerializableEvent: Codable, Sendable {
    let name: String
    let parameters: [String: String]?
    let timestamp: Date
}

/// Analytics 매니저 (여러 제공자 관리 + 이벤트 큐잉)
public actor AnalyticsManager {
    private var providers: [any AnalyticsProvider] = []
    private var eventQueue: [QueuedEvent] = []
    private let maxQueueSize: Int
    private let batchSize: Int
    private let flushInterval: TimeInterval
    private var flushTask: Task<Void, Never>?
    
    public static let shared = AnalyticsManager()
    
    public init(
        maxQueueSize: Int = 100,
        batchSize: Int = 10,
        flushInterval: TimeInterval = 30.0
    ) {
        self.maxQueueSize = maxQueueSize
        self.batchSize = batchSize
        self.flushInterval = flushInterval
        
        // 자동 플러시 시작
        startAutoFlush()
    }
    
    /// Analytics 제공자 추가
    public func addProvider(_ provider: any AnalyticsProvider) {
        providers.append(provider)
    }
    
    /// Analytics 제공자 제거
    public func removeAllProviders() {
        providers.removeAll()
    }
    
    /// 이벤트 로깅 (큐잉)
    public func logEvent(_ event: AnalyticsEvent) {
        // 이벤트를 큐에 추가
        let serializableEvent = SerializableEvent(
            name: event.name,
            parameters: event.parameters?.mapValues { "\($0)" },
            timestamp: event.timestamp
        )
        let queuedEvent = QueuedEvent(event: serializableEvent, timestamp: Date())
        eventQueue.append(queuedEvent)
        
        // 큐 크기 체크
        if eventQueue.count >= maxQueueSize {
            Task { await flush() }
        }
    }
    
    /// 이벤트 로깅 (즉시)
    public func logEventImmediately(_ event: AnalyticsEvent) async {
        await sendToProviders(event)
    }
    
    /// 사용자 속성 설정
    public func setUserProperty(key: String, value: String) async {
        for provider in providers {
            await provider.setUserProperty(key: key, value: value)
        }
    }
    
    /// 사용자 ID 설정
    public func setUserId(_ userId: String?) async {
        for provider in providers {
            await provider.setUserId(userId)
        }
    }
    
    /// 이벤트 플러시 (배치 전송)
    public func flush() async {
        guard !eventQueue.isEmpty else { return }
        
        // 배치로 나누어 전송
        let eventsToSend = Array(eventQueue.prefix(batchSize))
        eventQueue.removeFirst(min(batchSize, eventQueue.count))
        
        for queuedEvent in eventsToSend {
            let event = AnalyticsEvent(
                name: queuedEvent.event.name,
                parameters: queuedEvent.event.parameters,
                timestamp: queuedEvent.event.timestamp
            )
            await sendToProviders(event)
        }
        
        // 남은 이벤트가 있으면 재귀 호출
        if !eventQueue.isEmpty {
            await flush()
        }
    }
    
    /// 자동 플러시 시작
    private func startAutoFlush() {
        flushTask?.cancel()
        flushTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(flushInterval * 1_000_000_000))
                await flush()
            }
        }
    }
    
    /// 제공자에게 이벤트 전송
    private func sendToProviders(_ event: AnalyticsEvent) async {
        await withTaskGroup(of: Void.self) { group in
            for provider in providers {
                group.addTask {
                    await provider.logEvent(event)
                }
            }
        }
    }
    
    /// 매니저 정리
    public func shutdown() async {
        flushTask?.cancel()
        await flush()
    }
}

// MARK: - Convenience Methods

public extension AnalyticsManager {
    /// 화면 조회 이벤트
    func logScreenView(screenName: String, screenClass: String? = nil) {
        var parameters: [String: Any] = ["screen_name": screenName]
        if let screenClass = screenClass {
            parameters["screen_class"] = screenClass
        }
        logEvent(AnalyticsEvent(name: "screen_view", parameters: parameters))
    }
    
    /// 버튼 클릭 이벤트
    func logButtonTap(buttonName: String, screenName: String? = nil) {
        var parameters: [String: Any] = ["button_name": buttonName]
        if let screenName = screenName {
            parameters["screen_name"] = screenName
        }
        logEvent(AnalyticsEvent(name: "button_tap", parameters: parameters))
    }
    
    /// 에러 이벤트
    func logError(error: any Error, context: String? = nil) {
        var parameters: [String: Any] = [
            "error_description": error.localizedDescription,
            "error_type": "\(type(of: error))"
        ]
        if let context = context {
            parameters["context"] = context
        }
        logEvent(AnalyticsEvent(name: "error_occurred", parameters: parameters))
    }
}

