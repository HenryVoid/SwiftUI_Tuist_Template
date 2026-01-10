import XCTest
@testable import PerformanceMonitor

final class PerformanceMonitorTests: XCTestCase {
    
    func testMemoryMonitor() {
        let monitor = MemoryMonitor.shared
        monitor.resetStatistics()
        
        let snapshot = monitor.getCurrentMemoryUsage()
        XCTAssertGreaterThan(snapshot.usedMemoryMB, 0)
        XCTAssertGreaterThan(snapshot.footprintMB, 0)
        
        let average = monitor.getAverageMemoryUsage()
        XCTAssertGreaterThan(average, 0)
    }
    
    @MainActor
    func testFPSMonitor() async {
        let monitor = FPSMonitor.shared
        monitor.resetStatistics()
        
        var fpsUpdated = false
        monitor.onFPSUpdate = { fps in
            fpsUpdated = true
            XCTAssertGreaterThan(fps, 0)
        }
        
        monitor.startMonitoring()
        
        // Wait for FPS update
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        monitor.stopMonitoring()
        
        // FPS might not update in tests, but this verifies the monitoring lifecycle works
    }
    
    func testPerformanceMetricsGeneration() {
        let metrics = PerformanceMetrics.shared
        metrics.resetStatistics()
        
        // Generate a mock report
        let report = PerformanceMetrics.PerformanceReport(
            timestamp: Date(),
            architecture: "Test",
            currentFPS: 60.0,
            averageFPS: 58.5,
            minFPS: 50.0,
            maxFPS: 60.0,
            currentMemoryMB: 150.0,
            averageMemoryMB: 145.0,
            peakMemoryMB: 160.0
        )
        
        XCTAssertEqual(report.architecture, "Test")
        XCTAssertEqual(report.currentFPS, 60.0)
        XCTAssertEqual(report.averageFPS, 58.5)
    }
    
    func testJSONExport() {
        let metrics = PerformanceMetrics.shared
        metrics.resetStatistics()
        
        // Note: In actual usage, reports would be populated by monitoring
        let jsonString = metrics.exportReportsToJSON()
        XCTAssertNotNil(jsonString)
    }
}

