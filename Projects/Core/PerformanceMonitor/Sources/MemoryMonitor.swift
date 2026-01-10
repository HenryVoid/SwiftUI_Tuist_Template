import Foundation
import mach_o

/// Memory Monitor
public class MemoryMonitor {
    public static let shared = MemoryMonitor()
    
    private var memoryHistory: [MemorySnapshot] = []
    private let maxHistoryCount = 100
    
    public struct MemorySnapshot {
        public let timestamp: Date
        public let usedMemoryMB: Double
        public let footprintMB: Double
        
        public init(timestamp: Date, usedMemoryMB: Double, footprintMB: Double) {
            self.timestamp = timestamp
            self.usedMemoryMB = usedMemoryMB
            self.footprintMB = footprintMB
        }
    }
    
    private init() {}
    
    public func getCurrentMemoryUsage() -> MemorySnapshot {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                          task_flavor_t(MACH_TASK_BASIC_INFO),
                          $0,
                          &count)
            }
        }
        
        guard kerr == KERN_SUCCESS else {
            return MemorySnapshot(timestamp: Date(), usedMemoryMB: 0, footprintMB: 0)
        }
        
        let usedMemoryMB = Double(taskInfo.resident_size) / 1024.0 / 1024.0
        let footprintMB = Double(taskInfo.phys_footprint) / 1024.0 / 1024.0
        
        let snapshot = MemorySnapshot(
            timestamp: Date(),
            usedMemoryMB: usedMemoryMB,
            footprintMB: footprintMB
        )
        
        memoryHistory.append(snapshot)
        if memoryHistory.count > maxHistoryCount {
            memoryHistory.removeFirst()
        }
        
        return snapshot
    }
    
    public func getAverageMemoryUsage() -> Double {
        guard !memoryHistory.isEmpty else { return 0.0 }
        let total = memoryHistory.reduce(0.0) { $0 + $1.usedMemoryMB }
        return total / Double(memoryHistory.count)
    }
    
    public func getPeakMemoryUsage() -> Double {
        return memoryHistory.map { $0.usedMemoryMB }.max() ?? 0.0
    }
    
    public func getMemoryHistory() -> [MemorySnapshot] {
        return memoryHistory
    }
    
    public func resetStatistics() {
        memoryHistory.removeAll()
    }
}

