import Foundation
import Logger
import AnalyticsKit

/// Performance Metrics Collector
public class PerformanceMetrics {
    public static let shared = PerformanceMetrics()
    
    private let fpsMonitor = FPSMonitor.shared
    private let memoryMonitor = MemoryMonitor.shared
    
    private var isMonitoring: Bool = false
    private var monitoringTimer: Timer?
    
    public struct PerformanceReport: Codable {
        public let timestamp: Date
        public let architecture: String
        
        // FPS Metrics
        public let currentFPS: Double
        public let averageFPS: Double
        public let minFPS: Double
        public let maxFPS: Double
        
        // Memory Metrics
        public let currentMemoryMB: Double
        public let averageMemoryMB: Double
        public let peakMemoryMB: Double
        
        // Scroll Performance (if tracked)
        public let averageScrollFPS: Double?
        
        public init(
            timestamp: Date,
            architecture: String,
            currentFPS: Double,
            averageFPS: Double,
            minFPS: Double,
            maxFPS: Double,
            currentMemoryMB: Double,
            averageMemoryMB: Double,
            peakMemoryMB: Double,
            averageScrollFPS: Double? = nil
        ) {
            self.timestamp = timestamp
            self.architecture = architecture
            self.currentFPS = currentFPS
            self.averageFPS = averageFPS
            self.minFPS = minFPS
            self.maxFPS = maxFPS
            self.currentMemoryMB = currentMemoryMB
            self.averageMemoryMB = averageMemoryMB
            self.peakMemoryMB = peakMemoryMB
            self.averageScrollFPS = averageScrollFPS
        }
    }
    
    private var performanceReports: [PerformanceReport] = []
    
    private init() {}
    
    @MainActor
    public func startMonitoring(architecture: String) {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        fpsMonitor.startMonitoring()
        
        // Log performance metrics every 5 seconds
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let memorySnapshot = self.memoryMonitor.getCurrentMemoryUsage()
            
            let report = PerformanceReport(
                timestamp: Date(),
                architecture: architecture,
                currentFPS: self.fpsMonitor.getCurrentFPS(),
                averageFPS: self.fpsMonitor.getAverageFPS(),
                minFPS: self.fpsMonitor.getMinFPS(),
                maxFPS: self.fpsMonitor.getMaxFPS(),
                currentMemoryMB: memorySnapshot.usedMemoryMB,
                averageMemoryMB: self.memoryMonitor.getAverageMemoryUsage(),
                peakMemoryMB: self.memoryMonitor.getPeakMemoryUsage()
            )
            
            self.performanceReports.append(report)
            
            // Log to console and analytics
            Log.advanced(
                "Performance Metrics",
                level: .info,
                metadata: [
                    "arch": architecture,
                    "fps": String(format: "%.1f", report.currentFPS),
                    "avg_fps": String(format: "%.1f", report.averageFPS),
                    "memory_mb": String(format: "%.1f", report.currentMemoryMB),
                    "peak_memory_mb": String(format: "%.1f", report.peakMemoryMB)
                ]
            )
            
            AnalyticsManager.shared.logEvent(AnalyticsEvent(
                name: "performance_metrics",
                parameters: [
                    "architecture": architecture,
                    "fps": report.currentFPS,
                    "avg_fps": report.averageFPS,
                    "memory_mb": report.currentMemoryMB
                ]
            ))
        }
        
        RunLoop.main.add(monitoringTimer!, forMode: .common)
    }
    
    public func stopMonitoring() {
        isMonitoring = false
        monitoringTimer?.invalidate()
        monitoringTimer = nil
        
        Task { @MainActor in
            fpsMonitor.stopMonitoring()
        }
    }
    
    public func getPerformanceReports() -> [PerformanceReport] {
        return performanceReports
    }
    
    public func generateSummaryReport(architecture: String) -> PerformanceReport? {
        let reportsForArch = performanceReports.filter { $0.architecture == architecture }
        guard !reportsForArch.isEmpty else { return nil }
        
        let avgFPS = reportsForArch.reduce(0.0) { $0 + $1.averageFPS } / Double(reportsForArch.count)
        let minFPS = reportsForArch.map { $0.minFPS }.min() ?? 0.0
        let maxFPS = reportsForArch.map { $0.maxFPS }.max() ?? 0.0
        let avgMemory = reportsForArch.reduce(0.0) { $0 + $1.currentMemoryMB } / Double(reportsForArch.count)
        let peakMemory = reportsForArch.map { $0.peakMemoryMB }.max() ?? 0.0
        
        return PerformanceReport(
            timestamp: Date(),
            architecture: architecture,
            currentFPS: avgFPS,
            averageFPS: avgFPS,
            minFPS: minFPS,
            maxFPS: maxFPS,
            currentMemoryMB: avgMemory,
            averageMemoryMB: avgMemory,
            peakMemoryMB: peakMemory
        )
    }
    
    public func exportReportsToJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        guard let jsonData = try? encoder.encode(performanceReports),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        
        return jsonString
    }
    
    public func resetStatistics() {
        performanceReports.removeAll()
        fpsMonitor.resetStatistics()
        memoryMonitor.resetStatistics()
    }
}

