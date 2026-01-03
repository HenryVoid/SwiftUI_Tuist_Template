import Foundation

/// FileManager 기반 디스크 캐시
public actor DiskCache<Key: Hashable & Sendable, Value: Codable & Sendable>: CacheProtocol {
    private let fileManager: FileManager
    private let cacheDirectory: URL
    private let defaultExpiration: TimeInterval
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    public init(
        cacheDirectory: URL? = nil,
        defaultExpiration: TimeInterval = 86400 // 24시간
    ) throws {
        self.fileManager = .default
        self.defaultExpiration = defaultExpiration
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        
        // 캐시 디렉토리 설정
        if let directory = cacheDirectory {
            self.cacheDirectory = directory
        } else {
            guard let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                throw CacheError.diskWriteFailed
            }
            self.cacheDirectory = cachesDirectory.appendingPathComponent("DiskCache", isDirectory: true)
        }
        
        // 디렉토리 생성
        try? fileManager.createDirectory(at: self.cacheDirectory, withIntermediateDirectories: true)
    }
    
    private func fileURL(for key: Key) -> URL {
        let fileName = "\(abs(key.hashValue))"
        return cacheDirectory.appendingPathComponent(fileName)
    }
    
    public func get(_ key: Key) async throws -> Value {
        let fileURL = fileURL(for: key)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw CacheError.notFound
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let entry = try decoder.decode(CacheEntry<Value>.self, from: data)
            
            if entry.isExpired {
                try? fileManager.removeItem(at: fileURL)
                throw CacheError.expired
            }
            
            return entry.value
        } catch {
            throw CacheError.diskReadFailed
        }
    }
    
    public func set(_ value: Value, forKey key: Key, expiration: TimeInterval? = nil) async throws {
        let fileURL = fileURL(for: key)
        let expirationTime = expiration ?? defaultExpiration
        let expirationDate = Date().addingTimeInterval(expirationTime)
        
        let entry = CacheEntry(value: value, expirationDate: expirationDate)
        
        do {
            let data = try encoder.encode(entry)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw CacheError.diskWriteFailed
        }
    }
    
    public func remove(_ key: Key) async throws {
        let fileURL = fileURL(for: key)
        try? fileManager.removeItem(at: fileURL)
    }
    
    public func removeAll() async throws {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    /// 만료된 캐시 정리
    public func cleanExpiredCache() async throws {
        guard let enumerator = fileManager.enumerator(at: cacheDirectory, includingPropertiesForKeys: nil) else {
            return
        }
        
        for case let fileURL as URL in enumerator {
            guard let data = try? Data(contentsOf: fileURL),
                  let entry = try? decoder.decode(CacheEntry<Value>.self, from: data) else {
                continue
            }
            
            if entry.isExpired {
                try? fileManager.removeItem(at: fileURL)
            }
        }
    }
}

