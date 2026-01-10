import XCTest
@testable import AnalyticsKit

final class AnalyticsKitTests: XCTestCase {
    
    func testEventQueueing() async throws {
        // Given
        let manager = AnalyticsManager(maxQueueSize: 5, batchSize: 2)
        let testProvider = TestAnalyticsProvider()
        await manager.addProvider(testProvider)
        
        // When
        for i in 1...3 {
            let event = AnalyticsEvent(name: "test_event_\(i)")
            manager.logEvent(event)
        }
        
        await manager.flush()
        
        // Then
        let eventCount = await testProvider.getEventCount()
        XCTAssertEqual(eventCount, 3)
    }
    
    func testBatchSending() async throws {
        // Given
        let manager = AnalyticsManager(maxQueueSize: 100, batchSize: 10)
        let testProvider = TestAnalyticsProvider()
        await manager.addProvider(testProvider)
        
        // When
        for i in 1...15 {
            let event = AnalyticsEvent(name: "batch_event_\(i)")
            manager.logEvent(event)
        }
        
        await manager.flush()
        
        // Then
        let eventCount = await testProvider.getEventCount()
        XCTAssertEqual(eventCount, 15)
    }
    
    func testMultipleProviders() async throws {
        // Given
        let manager = AnalyticsManager()
        let provider1 = TestAnalyticsProvider()
        let provider2 = TestAnalyticsProvider()
        
        await manager.addProvider(provider1)
        await manager.addProvider(provider2)
        
        // When
        let event = AnalyticsEvent(name: "multi_provider_event")
        await manager.logEventImmediately(event)
        
        // Then
        let count1 = await provider1.getEventCount()
        let count2 = await provider2.getEventCount()
        
        XCTAssertEqual(count1, 1)
        XCTAssertEqual(count2, 1)
    }
    
    func testConvenienceMethods() async throws {
        // Given
        let manager = AnalyticsManager()
        let testProvider = TestAnalyticsProvider()
        await manager.addProvider(testProvider)
        
        // When
        await manager.logScreenView(screenName: "HomeScreen")
        await manager.logButtonTap(buttonName: "SubmitButton", screenName: "FormScreen")
        
        await manager.flush()
        
        // Then
        let eventCount = await testProvider.getEventCount()
        XCTAssertEqual(eventCount, 2)
    }
}

// MARK: - Test Helper

actor TestAnalyticsProvider: AnalyticsProvider {
    private var eventCount = 0
    
    func logEvent(_ event: AnalyticsEvent) async {
        eventCount += 1
    }
    
    func setUserProperty(key: String, value: String) async {}
    
    func setUserId(_ userId: String?) async {}
    
    func getEventCount() -> Int {
        return eventCount
    }
}

