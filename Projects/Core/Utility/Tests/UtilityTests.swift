import XCTest
@testable import Utility

final class UtilityTests: XCTestCase {
    
    func testDIContainer() {
        let container = DIContainer.shared
        container.clearAll()
        
        // Register a service
        container.register(String.self) {
            return "TestService"
        }
        
        // Resolve the service
        let service = container.resolve(String.self)
        XCTAssertEqual(service, "TestService")
    }
    
    func testUserDefaultsWrapper() {
        @UserDefault(key: "test_key", defaultValue: "default")
        var testValue: String
        
        // Test default value
        XCTAssertEqual(testValue, "default")
        
        // Test setter
        testValue = "new_value"
        XCTAssertEqual(testValue, "new_value")
        
        // Clean up
        UserDefaults.standard.removeObject(forKey: "test_key")
    }
    
    func testKeychainManager() {
        let keychain = KeychainManager.shared
        let testKey = "test_keychain_key"
        let testData = "TestData".data(using: .utf8)!
        
        // Save
        let saveStatus = keychain.save(key: testKey, data: testData)
        XCTAssertEqual(saveStatus, errSecSuccess)
        
        // Load
        let loadedData = keychain.load(key: testKey)
        XCTAssertEqual(loadedData, testData)
        
        // Delete
        let deleteStatus = keychain.delete(key: testKey)
        XCTAssertEqual(deleteStatus, errSecSuccess)
    }
    
    func testMemoryOptimizer() {
        let optimizer = MemoryOptimizer.shared
        let memoryBefore = optimizer.currentMemoryUsage()
        
        XCTAssertGreaterThan(memoryBefore, 0.0)
        
        optimizer.optimizeMemory()
        
        // Memory should still be measurable after optimization
        let memoryAfter = optimizer.currentMemoryUsage()
        XCTAssertGreaterThan(memoryAfter, 0.0)
    }
}

