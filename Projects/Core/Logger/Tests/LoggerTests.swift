import XCTest
@testable import Logger

final class LoggerTests: XCTestCase {
    
    func testLogLevelFiltering() async throws {
        // Given
        let storage = try FileLogStorage()
        let logger = try AdvancedLogger(storage: storage, minimumLevel: .info)
        
        // When
        await logger.log("Debug message", level: .debug)
        await logger.log("Info message", level: .info)
        await logger.log("Error message", level: .error)
        
        // Then
        let logs = try await logger.fetchLogs()
        
        // Debug는 필터링되어야 함
        XCTAssertFalse(logs.contains { $0.message == "Debug message" })
        XCTAssertTrue(logs.contains { $0.message == "Info message" })
        XCTAssertTrue(logs.contains { $0.message == "Error message" })
        
        // Cleanup
        try await logger.clearLogs()
    }
    
    func testFileLogStorage() async throws {
        // Given
        let storage = try FileLogStorage()
        let entry = LogEntry(
            level: "INFO",
            category: "Test",
            message: "Test message"
        )
        
        // When
        try await storage.save(entry)
        let logs = try await storage.fetchLogs()
        
        // Then
        XCTAssertTrue(logs.contains { $0.message == "Test message" })
        
        // Cleanup
        try await storage.clearLogs()
    }
    
    func testLogWithMetadata() async throws {
        // Given
        let storage = try FileLogStorage()
        let logger = try AdvancedLogger(storage: storage)
        
        // When
        await logger.log(
            "Test with metadata",
            level: .info,
            metadata: ["userId": "123", "action": "login"]
        )
        
        // Then
        let logs = try await logger.fetchLogs()
        let savedLog = logs.first { $0.message == "Test with metadata" }
        
        XCTAssertNotNil(savedLog)
        XCTAssertEqual(savedLog?.metadata?["userId"], "123")
        XCTAssertEqual(savedLog?.metadata?["action"], "login")
        
        // Cleanup
        try await logger.clearLogs()
    }
}

