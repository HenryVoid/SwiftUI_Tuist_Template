import Foundation

/// 원격 로그 전송 프로토콜
public protocol RemoteLogSender: Sendable {
    func send(_ logs: [LogEntry]) async throws
}

/// HTTP 기반 원격 로그 전송
public actor HTTPRemoteLogSender: RemoteLogSender {
    private let endpoint: URL
    private let session: URLSession
    private let batchSize: Int
    
    public init(
        endpoint: URL,
        session: URLSession = .shared,
        batchSize: Int = 50
    ) {
        self.endpoint = endpoint
        self.session = session
        self.batchSize = batchSize
    }
    
    public func send(_ logs: [LogEntry]) async throws {
        // 배치로 나누어 전송
        let batches = logs.chunked(into: batchSize)
        
        for batch in batches {
            try await sendBatch(batch)
        }
    }
    
    private func sendBatch(_ logs: [LogEntry]) async throws {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(logs)
        request.httpBody = data
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "RemoteLogSender", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to send logs"])
        }
    }
}

// MARK: - Array Extension

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

