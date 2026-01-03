import Foundation

/// 메모리 최적화 유틸리티
public actor MemoryOptimizer {
    public static let shared = MemoryOptimizer()
    
    private var memoryWarningObserver: NSObjectProtocol?
    private var cleanupHandlers: [@Sendable () async -> Void] = []
    
    private init() {
        setupMemoryWarningObserver()
    }
    
    /// 메모리 경고 옵저버 설정
    private func setupMemoryWarningObserver() {
        memoryWarningObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task {
                await self?.handleMemoryWarning()
            }
        }
    }
    
    /// 메모리 경고 처리
    private func handleMemoryWarning() async {
        print("⚠️ [MemoryOptimizer] Memory warning received. Running cleanup handlers...")
        
        for handler in cleanupHandlers {
            await handler()
        }
    }
    
    /// 클린업 핸들러 등록
    public func registerCleanupHandler(_ handler: @Sendable @escaping () async -> Void) {
        cleanupHandlers.append(handler)
    }
    
    /// 모든 핸들러 제거
    public func removeAllHandlers() {
        cleanupHandlers.removeAll()
    }
    
    /// 현재 메모리 사용량 조회 (MB)
    public func currentMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else { return 0 }
        
        let usedBytes = Double(info.resident_size)
        let usedMB = usedBytes / 1024 / 1024
        
        return usedMB
    }
    
    deinit {
        if let observer = memoryWarningObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

#if canImport(UIKit)
import UIKit
#endif

