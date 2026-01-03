import Foundation

/// 하이브리드 캐시 (메모리 + 디스크)
public actor HybridCache<Key: Hashable & Sendable, Value: Codable & Sendable>: CacheProtocol {
    private let memoryCache: MemoryCache<Key, Value>
    private let diskCache: DiskCache<Key, Value>
    
    public init(
        memoryCountLimit: Int = 100,
        memoryCostLimit: Int = 50 * 1024 * 1024, // 50MB
        memoryExpiration: TimeInterval = 3600, // 1시간
        diskExpiration: TimeInterval = 86400 // 24시간
    ) throws {
        self.memoryCache = MemoryCache<Key, Value>(
            countLimit: memoryCountLimit,
            totalCostLimit: memoryCostLimit,
            defaultExpiration: memoryExpiration
        )
        
        self.diskCache = try DiskCache<Key, Value>(
            defaultExpiration: diskExpiration
        )
    }
    
    public func get(_ key: Key) async throws -> Value {
        // 메모리 캐시 확인
        if let value = try? await memoryCache.get(key) {
            return value
        }
        
        // 디스크 캐시 확인
        let value = try await diskCache.get(key)
        
        // 메모리 캐시에도 저장
        try? await memoryCache.set(value, forKey: key, expiration: nil)
        
        return value
    }
    
    public func set(_ value: Value, forKey key: Key, expiration: TimeInterval? = nil) async throws {
        // 메모리와 디스크 모두에 저장
        try await memoryCache.set(value, forKey: key, expiration: expiration)
        try await diskCache.set(value, forKey: key, expiration: expiration)
    }
    
    public func remove(_ key: Key) async throws {
        try await memoryCache.remove(key)
        try await diskCache.remove(key)
    }
    
    public func removeAll() async throws {
        try await memoryCache.removeAll()
        try await diskCache.removeAll()
    }
    
    /// 디스크 캐시 정리
    public func cleanDiskCache() async throws {
        try await diskCache.cleanExpiredCache()
    }
}

