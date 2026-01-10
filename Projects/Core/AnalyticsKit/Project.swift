import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "AnalyticsKit",
    organizationName: organizationName,
    product: .staticLibrary,
    bundleId: bundleID + "AnalyticsKit",
    dependencies: [
        .core(module: .Logger)
    ],
    settings: .core(),
    hasTest: true
)

