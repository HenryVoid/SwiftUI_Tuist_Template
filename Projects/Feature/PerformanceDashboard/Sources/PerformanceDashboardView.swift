import SwiftUI
import PerformanceMonitor
import CacheKit
import DesignSystem

public struct PerformanceDashboardView: View {
    @StateObject private var viewModel = PerformanceDashboardViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Architecture Comparison
                    architectureComparison
                    
                    Divider()
                    
                    // FPS Metrics
                    fpsMetrics
                    
                    Divider()
                    
                    // Memory Metrics
                    memoryMetrics
                    
                    Divider()
                    
                    // Cache Statistics
                    cacheStatistics
                    
                    Divider()
                    
                    // Export Button
                    exportButton
                }
                .padding()
            }
            .navigationTitle("Performance Dashboard")
            .task {
                await viewModel.loadData()
            }
            .refreshable {
                await viewModel.loadData()
            }
        }
    }
    
    private var architectureComparison: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Architecture Comparison")
                .title2(.bold)
            
            ForEach(["MVVM+Clean", "TCA", "ReactorKit"], id: \.self) { arch in
                if let report = viewModel.getSummaryReport(for: arch) {
                    ArchitectureCard(architecture: arch, report: report)
                }
            }
        }
    }
    
    private var fpsMetrics: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FPS Performance")
                .title2(.bold)
            
            HStack(spacing: 16) {
                MetricCard(
                    title: "Current FPS",
                    value: String(format: "%.1f", viewModel.currentFPS),
                    icon: "speedometer",
                    color: viewModel.currentFPS >= 55 ? .green : .red
                )
                
                MetricCard(
                    title: "Average FPS",
                    value: String(format: "%.1f", viewModel.averageFPS),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )
            }
            
            HStack(spacing: 16) {
                MetricCard(
                    title: "Min FPS",
                    value: String(format: "%.1f", viewModel.minFPS),
                    icon: "arrow.down.circle",
                    color: .orange
                )
                
                MetricCard(
                    title: "Max FPS",
                    value: String(format: "%.1f", viewModel.maxFPS),
                    icon: "arrow.up.circle",
                    color: .green
                )
            }
        }
    }
    
    private var memoryMetrics: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Memory Usage")
                .title2(.bold)
            
            HStack(spacing: 16) {
                MetricCard(
                    title: "Current Memory",
                    value: String(format: "%.1f MB", viewModel.currentMemoryMB),
                    icon: "memorychip",
                    color: .purple
                )
                
                MetricCard(
                    title: "Peak Memory",
                    value: String(format: "%.1f MB", viewModel.peakMemoryMB),
                    icon: "chart.bar.fill",
                    color: .red
                )
            }
        }
    }
    
    private var cacheStatistics: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Image Cache Statistics")
                .title2(.bold)
            
            HStack(spacing: 16) {
                MetricCard(
                    title: "Cache Size",
                    value: String(format: "%.1f MB", viewModel.cacheSizeMB),
                    icon: "externaldrive",
                    color: .cyan
                )
                
                MetricCard(
                    title: "Hit Rate",
                    value: String(format: "%.1f%%", viewModel.cacheHitRate * 100),
                    icon: "target",
                    color: viewModel.cacheHitRate >= 0.7 ? .green : .orange
                )
            }
            
            MetricCard(
                title: "Cached Images",
                value: "\(viewModel.cachedImagesCount)",
                icon: "photo.stack",
                color: .indigo
            )
        }
    }
    
    private var exportButton: some View {
        Button {
            viewModel.exportReports()
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Export Performance Reports")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .alert("Export Successful", isPresented: $viewModel.showExportAlert) {
            Button("OK") {}
        } message: {
            Text("Performance reports have been exported")
        }
    }
}

struct ArchitectureCard: View {
    let architecture: String
    let report: PerformanceMetrics.PerformanceReport
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(architecture)
                .subtitle1(.bold)
            
            HStack {
                Label(String(format: "FPS: %.1f", report.averageFPS), systemImage: "speedometer")
                    .font(.caption)
                
                Spacer()
                
                Label(String(format: "Memory: %.1f MB", report.averageMemoryMB), systemImage: "memorychip")
                    .font(.caption)
            }
            .foregroundStyle(.gray600)
        }
        .padding()
        .background(Color.gray50)
        .cornerRadius(12)
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .title3(.bold)
                .foregroundStyle(.gray900)
            
            Text(title)
                .body3(.regular)
                .foregroundStyle(.gray600)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray50)
        .cornerRadius(12)
    }
}

@MainActor
class PerformanceDashboardViewModel: ObservableObject {
    @Published var currentFPS: Double = 60.0
    @Published var averageFPS: Double = 60.0
    @Published var minFPS: Double = 60.0
    @Published var maxFPS: Double = 60.0
    
    @Published var currentMemoryMB: Double = 0.0
    @Published var peakMemoryMB: Double = 0.0
    
    @Published var cacheSizeMB: Double = 0.0
    @Published var cacheHitRate: Double = 0.0
    @Published var cachedImagesCount: Int = 0
    
    @Published var showExportAlert: Bool = false
    
    private let fpsMonitor = FPSMonitor.shared
    private let memoryMonitor = MemoryMonitor.shared
    private let performanceMetrics = PerformanceMetrics.shared
    
    func loadData() async {
        // FPS Data
        currentFPS = fpsMonitor.getCurrentFPS()
        averageFPS = fpsMonitor.getAverageFPS()
        minFPS = fpsMonitor.getMinFPS()
        maxFPS = fpsMonitor.getMaxFPS()
        
        // Memory Data
        let memorySnapshot = memoryMonitor.getCurrentMemoryUsage()
        currentMemoryMB = memorySnapshot.usedMemoryMB
        peakMemoryMB = memoryMonitor.getPeakMemoryUsage()
        
        // Cache Data
        let cacheStats = await ImageCache.shared.getCacheStatistics()
        cacheSizeMB = Double(cacheStats.cacheSize) / 1024.0 / 1024.0
        cacheHitRate = cacheStats.hitRate
        cachedImagesCount = cacheStats.totalCachedImages
    }
    
    func getSummaryReport(for architecture: String) -> PerformanceMetrics.PerformanceReport? {
        return performanceMetrics.generateSummaryReport(architecture: architecture)
    }
    
    func exportReports() {
        guard let jsonString = performanceMetrics.exportReportsToJSON() else {
            return
        }
        
        // Save to Documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsPath.appendingPathComponent("performance_reports_\(Date().timeIntervalSince1970).json")
        
        do {
            try jsonString.write(to: filePath, atomically: true, encoding: .utf8)
            showExportAlert = true
            
            Log.advanced(
                "Performance reports exported",
                level: .info,
                metadata: ["path": filePath.path]
            )
        } catch {
            Log.advanced(
                "Failed to export reports",
                level: .error,
                metadata: ["error": error.localizedDescription]
            )
        }
    }
}

