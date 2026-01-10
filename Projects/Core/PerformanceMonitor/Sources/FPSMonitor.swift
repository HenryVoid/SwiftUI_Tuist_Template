import Foundation
import UIKit
import QuartzCore

/// FPS Monitor
@MainActor
public class FPSMonitor {
    public static let shared = FPSMonitor()
    
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount: Int = 0
    private var currentFPS: Double = 60.0
    
    private var fpsHistory: [Double] = []
    private let maxHistoryCount = 60 // Store last 60 FPS measurements
    
    public var onFPSUpdate: ((Double) -> Void)?
    
    private init() {}
    
    public func startMonitoring() {
        guard displayLink == nil else { return }
        
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkTick))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    public func stopMonitoring() {
        displayLink?.invalidate()
        displayLink = nil
        frameCount = 0
        lastTimestamp = 0
    }
    
    @objc private func displayLinkTick(_ link: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }
        
        frameCount += 1
        let elapsed = link.timestamp - lastTimestamp
        
        if elapsed >= 1.0 {
            currentFPS = Double(frameCount) / elapsed
            fpsHistory.append(currentFPS)
            
            if fpsHistory.count > maxHistoryCount {
                fpsHistory.removeFirst()
            }
            
            onFPSUpdate?(currentFPS)
            
            frameCount = 0
            lastTimestamp = link.timestamp
        }
    }
    
    public func getCurrentFPS() -> Double {
        return currentFPS
    }
    
    public func getAverageFPS() -> Double {
        guard !fpsHistory.isEmpty else { return 60.0 }
        return fpsHistory.reduce(0, +) / Double(fpsHistory.count)
    }
    
    public func getMinFPS() -> Double {
        return fpsHistory.min() ?? 60.0
    }
    
    public func getMaxFPS() -> Double {
        return fpsHistory.max() ?? 60.0
    }
    
    public func resetStatistics() {
        fpsHistory.removeAll()
        currentFPS = 60.0
    }
}

