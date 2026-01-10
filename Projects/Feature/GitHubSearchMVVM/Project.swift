import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "GitHubSearchMVVM",
    organizationName: organizationName,
    product: .framework,
    bundleId: bundleID + "GitHubSearchMVVM",
    dependencies: [
        .core(module: .GitHubService),
        .core(module: .CoreKit),
        .core(module: .CacheKit),
        .core(module: .NetworkKit),
        .core(module: .Logger),
        .core(module: .AnalyticsKit),
        .core(module: .Utility),
        .design(module: .DesignSystem)
    ],
    settings: .feature("GitHubSearchMVVM"),
    hasTest: true,
    hasDemo: true
)

