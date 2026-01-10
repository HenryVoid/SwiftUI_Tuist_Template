import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "PerformanceDashboard",
    organizationName: organizationName,
    product: .framework,
    bundleId: bundleID + "PerformanceDashboard",
    dependencies: [
        .core(module: .PerformanceMonitor),
        .core(module: .CacheKit),
        .core(module: .Logger),
        .design(module: .DesignSystem)
    ],
    settings: .feature("PerformanceDashboard"),
    hasTest: false,
    hasDemo: true
)

