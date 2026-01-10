import Foundation
import OSLog

/// 고급 로거 (파일 저장 + 원격 전송 지원)
public actor AdvancedLogger {
    private let storage: (any LogStorage)?
    private let remoteSender: (any RemoteLogSender)?
    private let minimumLevel: Log.LogLevel
    
    public static let shared = try! AdvancedLogger()
    
    public init(
        storage: (any LogStorage)? = nil,
        remoteSender: (any RemoteLogSender)? = nil,
        minimumLevel: Log.LogLevel = .debug
    ) throws {
        self.storage = storage ?? (try? FileLogStorage())
        self.remoteSender = remoteSender
        self.minimumLevel = minimumLevel
    }
    
    /// 로그 기록
    public func log(
        _ message: String,
        level: Log.LogLevel,
        category: String? = nil,
        metadata: [String: String]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) async {
        // 레벨 필터링
        guard shouldLog(level: level) else { return }
        
        let categoryName = category ?? level.category
        let fileName = (file as NSString).lastPathComponent
        
        let enrichedMetadata = [
            "file": fileName,
            "function": function,
            "line": "\(line)"
        ].merging(metadata ?? [:]) { _, new in new }
        
        let logEntry = LogEntry(
            level: level.category,
            category: categoryName,
            message: message,
            metadata: enrichedMetadata
        )
        
        // OSLog 출력
        #if DEBUG
        let logger = Logger(subsystem: OSLog.subsystem, category: categoryName)
        switch level {
        case .debug, .custom:
            logger.debug("\(message)")
        case .info:
            logger.info("\(message)")
        case .network:
            logger.log("\(message)")
        case .error:
            logger.error("\(message)")
        }
        #endif
        
        // 파일 저장
        try? await storage?.save(logEntry)
    }
    
    /// 로그 레벨 필터링
    private func shouldLog(level: Log.LogLevel) -> Bool {
        let levels: [Log.LogLevel] = [.debug, .info, .network, .error]
        guard let currentIndex = levels.firstIndex(where: { "\($0)" == "\(level)" }),
              let minimumIndex = levels.firstIndex(where: { "\($0)" == "\(minimumLevel)" }) else {
            return true
        }
        return currentIndex >= minimumIndex
    }
    
    /// 로그 조회
    public func fetchLogs(limit: Int? = 100) async throws -> [LogEntry] {
        guard let storage = storage else { return [] }
        return try await storage.fetchLogs(limit: limit)
    }
    
    /// 로그 전송
    public func flushLogs() async throws {
        guard let storage = storage,
              let remoteSender = remoteSender else { return }
        
        let logs = try await storage.fetchLogs(limit: nil)
        
        if !logs.isEmpty {
            try await remoteSender.send(logs)
            // 전송 성공 시 로컬 로그 삭제
            try await storage.clearLogs()
        }
    }
    
    /// 로그 삭제
    public func clearLogs() async throws {
        try await storage?.clearLogs()
    }
}

// MARK: - Public Extensions

public extension Log {
    /// 고급 로거 사용
    static func advanced(
        _ message: String,
        level: LogLevel,
        category: String? = nil,
        metadata: [String: String]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        Task {
            await AdvancedLogger.shared.log(
                message,
                level: level,
                category: category,
                metadata: metadata,
                file: file,
                function: function,
                line: line
            )
        }
    }
}

