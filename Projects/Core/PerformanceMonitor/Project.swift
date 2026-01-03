import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "PerformanceMonitor",
    organizationName: organizationName,
    product: .staticLibrary,
    bundleId: bundleID + "PerformanceMonitor",
    dependencies: [
        .core(module: .Logger),
        .core(module: .AnalyticsKit)
    ],
    settings: .core(),
    hasTest: true
)

