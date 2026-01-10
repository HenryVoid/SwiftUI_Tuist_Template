import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "GitHubService",
    organizationName: organizationName,
    product: .framework,
    bundleId: bundleID + "GitHubService",
    dependencies: [
        .core(module: .NetworkKit),
        .core(module: .CacheKit),
        .core(module: .Logger)
    ],
    settings: .core(),
    hasTest: true
)

