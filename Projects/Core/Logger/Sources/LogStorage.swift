import Foundation

/// 로그 저장 프로토콜
public protocol LogStorage: Sendable {
    func save(_ logEntry: LogEntry) async throws
    func fetchLogs(limit: Int?) async throws -> [LogEntry]
    func clearLogs() async throws
}

/// 로그 항목
public struct LogEntry: Codable, Sendable, Identifiable {
    public let id: UUID
    public let timestamp: Date
    public let level: String
    public let category: String
    public let message: String
    public let metadata: [String: String]?
    
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        level: String,
        category: String,
        message: String,
        metadata: [String: String]? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.level = level
        self.category = category
        self.message = message
        self.metadata = metadata
    }
}

