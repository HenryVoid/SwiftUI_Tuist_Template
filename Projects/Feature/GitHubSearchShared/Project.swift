import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "GitHubSearchShared",
    organizationName: organizationName,
    product: .framework,
    bundleId: bundleID + "GitHubSearchShared",
    dependencies: [
        .core(module: .GitHubServiceInterface),
        .core(module: .CacheKit),
        .design(module: .DesignSystem)
    ],
    settings: .feature("GitHubSearchShared"),
    hasTest: false
)
