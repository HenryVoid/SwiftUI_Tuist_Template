import Foundation
import Security

/// Keychain 에러
public enum KeychainError: Error, Sendable {
    case itemNotFound
    case duplicateItem
    case unexpectedStatus(OSStatus)
    case encodingFailed
    case decodingFailed
}

/// Keychain 매니저
public actor KeychainManager {
    public static let shared = KeychainManager()
    
    private init() {}
    
    /// 데이터 저장
    public func save(_ data: Data, forKey key: String, service: String = Bundle.main.bundleIdentifier ?? "com.app") throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // 기존 항목 삭제
        SecItemDelete(query as CFDictionary)
        
        // 새 항목 추가
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    /// 문자열 저장
    public func save(_ value: String, forKey key: String, service: String = Bundle.main.bundleIdentifier ?? "com.app") throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }
        try save(data, forKey: key, service: service)
    }
    
    /// Codable 객체 저장
    public func save<T: Codable>(_ value: T, forKey key: String, service: String = Bundle.main.bundleIdentifier ?? "com.app") throws {
        let data = try JSONEncoder().encode(value)
        try save(data, forKey: key, service: service)
    }
    
    /// 데이터 로드
    public func load(forKey key: String, service: String = Bundle.main.bundleIdentifier ?? "com.app") throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            throw status == errSecItemNotFound ? KeychainError.itemNotFound : KeychainError.unexpectedStatus(status)
        }
        
        guard let data = result as? Data else {
            throw KeychainError.decodingFailed
        }
        
        return data
    }
    
    /// 문자열 로드
    public func loadString(forKey key: String, service: String = Bundle.main.bundleIdentifier ?? "com.app") throws -> String {
        let data = try load(forKey: key, service: service)
        guard let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.decodingFailed
        }
        return string
    }
    
    /// Codable 객체 로드
    public func load<T: Codable>(forKey key: String, as type: T.Type, service: String = Bundle.main.bundleIdentifier ?? "com.app") throws -> T {
        let data = try load(forKey: key, service: service)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    /// 항목 삭제
    public func delete(forKey key: String, service: String = Bundle.main.bundleIdentifier ?? "com.app") throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    /// 모든 항목 삭제
    public func deleteAll(service: String = Bundle.main.bundleIdentifier ?? "com.app") throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}

