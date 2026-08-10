import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "GitHubSearchTCA",
    organizationName: organizationName,
    product: .framework,
    bundleId: bundleID + "GitHubSearchTCA",
    dependencies: [
        .core(module: .GitHubService),
        .core(module: .CoreKit),
        .core(module: .AnalyticsKit),
        .design(module: .DesignSystem),
        .external(name: "ComposableArchitecture")
    ],
    settings: .feature("GitHubSearchTCA"),
    hasTest: true,
    hasDemo: true
)

