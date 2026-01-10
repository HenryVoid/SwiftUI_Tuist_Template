import Foundation

/// NSCache 기반 메모리 캐시
public actor MemoryCache<Key: Hashable & Sendable, Value: Codable & Sendable>: CacheProtocol {
    private let cache = NSCache<NSString, CacheBox>()
    private let defaultExpiration: TimeInterval
    
    // NSCache는 Sendable이 아니므로 래퍼 클래스 사용
    private final class CacheBox: @unchecked Sendable {
        let entry: CacheEntry<Value>
        init(entry: CacheEntry<Value>) {
            self.entry = entry
        }
    }
    
    public init(
        countLimit: Int = 100,
        totalCostLimit: Int = 50 * 1024 * 1024, // 50MB
        defaultExpiration: TimeInterval = 3600 // 1시간
    ) {
        self.defaultExpiration = defaultExpiration
        cache.countLimit = countLimit
        cache.totalCostLimit = totalCostLimit
    }
    
    public func get(_ key: Key) async throws -> Value {
        let keyString = "\(key)" as NSString
        
        guard let box = cache.object(forKey: keyString) else {
            throw CacheError.notFound
        }
        
        let entry = box.entry
        
        if entry.isExpired {
            cache.removeObject(forKey: keyString)
            throw CacheError.expired
        }
        
        return entry.value
    }
    
    public func set(_ value: Value, forKey key: Key, expiration: TimeInterval? = nil) async throws {
        let keyString = "\(key)" as NSString
        let expirationTime = expiration ?? defaultExpiration
        let expirationDate = Date().addingTimeInterval(expirationTime)
        
        let entry = CacheEntry(value: value, expirationDate: expirationDate)
        let box = CacheBox(entry: entry)
        
        cache.setObject(box, forKey: keyString)
    }
    
    public func remove(_ key: Key) async throws {
        let keyString = "\(key)" as NSString
        cache.removeObject(forKey: keyString)
    }
    
    public func removeAll() async throws {
        cache.removeAllObjects()
    }
}

