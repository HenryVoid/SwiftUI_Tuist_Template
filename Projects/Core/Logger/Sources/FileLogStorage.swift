import Foundation

/// 파일 기반 로그 저장소
public actor FileLogStorage: LogStorage {
    private let fileManager: FileManager
    private let logFileURL: URL
    private let maxFileSize: Int
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    public init(
        logFileName: String = "app_logs.json",
        maxFileSize: Int = 10 * 1024 * 1024 // 10MB
    ) throws {
        self.fileManager = .default
        self.maxFileSize = maxFileSize
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        
        // 로그 파일 경로 설정
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "FileLogStorage", code: -1, userInfo: [NSLocalizedDescriptionKey: "Documents directory not found"])
        }
        
        let logsDirectory = documentsDirectory.appendingPathComponent("Logs", isDirectory: true)
        try? fileManager.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
        
        self.logFileURL = logsDirectory.appendingPathComponent(logFileName)
        
        // 파일이 없으면 생성
        if !fileManager.fileExists(atPath: logFileURL.path) {
            try? "[]".data(using: .utf8)?.write(to: logFileURL)
        }
    }
    
    public func save(_ logEntry: LogEntry) async throws {
        var logs = try await fetchLogs(limit: nil)
        logs.append(logEntry)
        
        // 파일 크기 체크 및 로테이션
        if let data = try? encoder.encode(logs),
           data.count > maxFileSize {
            // 오래된 로그 절반 삭제
            logs = Array(logs.suffix(logs.count / 2))
        }
        
        let data = try encoder.encode(logs)
        try data.write(to: logFileURL, options: .atomic)
    }
    
    public func fetchLogs(limit: Int? = nil) async throws -> [LogEntry] {
        guard fileManager.fileExists(atPath: logFileURL.path) else {
            return []
        }
        
        let data = try Data(contentsOf: logFileURL)
        var logs = try decoder.decode([LogEntry].self, from: data)
        
        if let limit = limit {
            logs = Array(logs.suffix(limit))
        }
        
        return logs
    }
    
    public func clearLogs() async throws {
        try "[]".data(using: .utf8)?.write(to: logFileURL)
    }
    
    /// 로그 파일 내보내기
    public func exportLogs() async throws -> URL {
        return logFileURL
    }
}

