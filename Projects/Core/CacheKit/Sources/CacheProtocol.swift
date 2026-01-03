import Foundation

/// 캐시 항목 래퍼 (만료 시간 포함)
struct CacheEntry<Value: Codable & Sendable>: Codable, Sendable {
    let value: Value
    let expirationDate: Date
    
    var isExpired: Bool {
        Date() > expirationDate
    }
}

/// 캐시 프로토콜
public protocol CacheProtocol: Sendable {
    associatedtype Key: Hashable & Sendable
    associatedtype Value: Codable & Sendable
    
    func get(_ key: Key) async throws -> Value
    func set(_ value: Value, forKey key: Key, expiration: TimeInterval?) async throws
    func remove(_ key: Key) async throws
    func removeAll() async throws
}

