import Foundation

/// UserDefaults Property Wrapper
@propertyWrapper
public struct UserDefault<T> {
    private let key: String
    private let defaultValue: T
    private let userDefaults: UserDefaults
    
    public init(key: String, defaultValue: T, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }
    
    public var wrappedValue: T {
        get {
            return userDefaults.object(forKey: key) as? T ?? defaultValue
        }
        set {
            userDefaults.set(newValue, forKey: key)
        }
    }
}

/// UserDefaults Codable Property Wrapper
@propertyWrapper
public struct UserDefaultCodable<T: Codable> {
    private let key: String
    private let defaultValue: T
    private let userDefaults: UserDefaults
    
    public init(key: String, defaultValue: T, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }
    
    public var wrappedValue: T {
        get {
            guard let data = userDefaults.data(forKey: key),
                  let value = try? JSONDecoder().decode(T.self, from: data) else {
                return defaultValue
            }
            return value
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            userDefaults.set(data, forKey: key)
        }
    }
}

/// UserDefaults 매니저
public actor UserDefaultsManager {
    private let userDefaults: UserDefaults
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    public func save<T>(_ value: T, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
    
    public func save<T: Codable>(_ value: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(value)
        userDefaults.set(data, forKey: key)
    }
    
    public func get<T>(_ key: String) -> T? {
        return userDefaults.object(forKey: key) as? T
    }
    
    public func get<T: Codable>(_ key: String, as type: T.Type) throws -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    public func remove(_ key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    public func removeAll() {
        if let bundleID = Bundle.main.bundleIdentifier {
            userDefaults.removePersistentDomain(forName: bundleID)
        }
    }
}

