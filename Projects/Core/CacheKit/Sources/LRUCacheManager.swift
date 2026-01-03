import Foundation

/// LRU (Least Recently Used) 캐시 매니저
public actor LRUCacheManager<Key: Hashable & Sendable, Value: Codable & Sendable>: CacheProtocol {
    private var cache: [Key: Node] = [:]
    private var head: Node?
    private var tail: Node?
    private let capacity: Int
    private var count: Int = 0
    private let defaultExpiration: TimeInterval
    
    // Doubly Linked List Node
    private final class Node: @unchecked Sendable {
        let key: Key
        var entry: CacheEntry<Value>
        var prev: Node?
        var next: Node?
        
        init(key: Key, entry: CacheEntry<Value>) {
            self.key = key
            self.entry = entry
        }
    }
    
    public init(capacity: Int = 100, defaultExpiration: TimeInterval = 3600) {
        self.capacity = capacity
        self.defaultExpiration = defaultExpiration
    }
    
    public func get(_ key: Key) async throws -> Value {
        guard let node = cache[key] else {
            throw CacheError.notFound
        }
        
        if node.entry.isExpired {
            await removeNode(node)
            cache.removeValue(forKey: key)
            throw CacheError.expired
        }
        
        // 가장 최근에 사용했으므로 head로 이동
        await moveToHead(node)
        
        return node.entry.value
    }
    
    public func set(_ value: Value, forKey key: Key, expiration: TimeInterval? = nil) async throws {
        let expirationTime = expiration ?? defaultExpiration
        let expirationDate = Date().addingTimeInterval(expirationTime)
        let entry = CacheEntry(value: value, expirationDate: expirationDate)
        
        if let existingNode = cache[key] {
            // 기존 노드 업데이트
            existingNode.entry = entry
            await moveToHead(existingNode)
        } else {
            // 새 노드 추가
            let newNode = Node(key: key, entry: entry)
            cache[key] = newNode
            await addToHead(newNode)
            count += 1
            
            // 용량 초과 시 LRU 제거
            if count > capacity {
                if let tailNode = tail {
                    await removeNode(tailNode)
                    cache.removeValue(forKey: tailNode.key)
                    count -= 1
                }
            }
        }
    }
    
    public func remove(_ key: Key) async throws {
        guard let node = cache[key] else { return }
        await removeNode(node)
        cache.removeValue(forKey: key)
        count -= 1
    }
    
    public func removeAll() async throws {
        cache.removeAll()
        head = nil
        tail = nil
        count = 0
    }
    
    // MARK: - Private Methods
    
    private func addToHead(_ node: Node) async {
        node.next = head
        node.prev = nil
        
        if let head = head {
            head.prev = node
        }
        
        head = node
        
        if tail == nil {
            tail = node
        }
    }
    
    private func removeNode(_ node: Node) async {
        if let prev = node.prev {
            prev.next = node.next
        } else {
            head = node.next
        }
        
        if let next = node.next {
            next.prev = node.prev
        } else {
            tail = node.prev
        }
        
        node.prev = nil
        node.next = nil
    }
    
    private func moveToHead(_ node: Node) async {
        await removeNode(node)
        await addToHead(node)
    }
    
    /// 캐시 상태 조회
    public func cacheInfo() async -> (count: Int, capacity: Int) {
        return (count, capacity)
    }
}

