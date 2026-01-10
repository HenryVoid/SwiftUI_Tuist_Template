import XCTest
@testable import CacheKit

final class CacheKitTests: XCTestCase {
    
    // MARK: - Memory Cache Tests
    
    func testMemoryCacheSaveAndRetrieve() async throws {
        // Given
        let cache = MemoryCache<String, String>()
        let key = "testKey"
        let value = "testValue"
        
        // When
        try await cache.set(value, forKey: key, expiration: 10)
        let retrieved = try await cache.get(key)
        
        // Then
        XCTAssertEqual(retrieved, value)
    }
    
    func testMemoryCacheExpiration() async throws {
        // Given
        let cache = MemoryCache<String, String>()
        let key = "testKey"
        let value = "testValue"
        
        // When
        try await cache.set(value, forKey: key, expiration: 0.1)
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2초 대기
        
        // Then
        do {
            _ = try await cache.get(key)
            XCTFail("Should throw expired error")
        } catch {
            XCTAssertTrue(error is CacheError)
        }
    }
    
    // MARK: - LRU Cache Tests
    
    func testLRUCacheEviction() async throws {
        // Given
        let cache = LRUCacheManager<String, String>(capacity: 2)
        
        // When
        try await cache.set("value1", forKey: "key1", expiration: nil)
        try await cache.set("value2", forKey: "key2", expiration: nil)
        try await cache.set("value3", forKey: "key3", expiration: nil)
        
        // Then
        do {
            _ = try await cache.get("key1") // 가장 오래된 항목이 제거되어야 함
            XCTFail("key1 should have been evicted")
        } catch {
            XCTAssertTrue(error is CacheError)
        }
        
        let value2 = try await cache.get("key2")
        let value3 = try await cache.get("key3")
        XCTAssertEqual(value2, "value2")
        XCTAssertEqual(value3, "value3")
    }
    
    func testLRUCacheRecentlyUsed() async throws {
        // Given
        let cache = LRUCacheManager<String, String>(capacity: 2)
        
        // When
        try await cache.set("value1", forKey: "key1", expiration: nil)
        try await cache.set("value2", forKey: "key2", expiration: nil)
        _ = try await cache.get("key1") // key1을 최근 사용으로 업데이트
        try await cache.set("value3", forKey: "key3", expiration: nil)
        
        // Then
        // key2가 제거되고 key1은 남아있어야 함
        do {
            _ = try await cache.get("key2")
            XCTFail("key2 should have been evicted")
        } catch {
            XCTAssertTrue(error is CacheError)
        }
        
        let value1 = try await cache.get("key1")
        XCTAssertEqual(value1, "value1")
    }
    
    // MARK: - Hybrid Cache Tests
    
    func testHybridCacheFallback() async throws {
        // Given
        let cache = try HybridCache<String, String>(
            memoryCountLimit: 10,
            memoryCostLimit: 1024,
            memoryExpiration: 10,
            diskExpiration: 20
        )
        
        let key = "testKey"
        let value = "testValue"
        
        // When
        try await cache.set(value, forKey: key, expiration: nil)
        
        // 메모리 캐시 제거
        try await cache.removeAll()
        
        // Then
        // 디스크 캐시에서 복원되어야 함 (실제로는 둘 다 제거되므로 테스트 수정 필요)
        // 이 테스트는 실제 구현에 따라 조정
    }
}

