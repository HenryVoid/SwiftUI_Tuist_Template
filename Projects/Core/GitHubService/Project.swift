import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "GitHubService",
    organizationName: organizationName,
    product: .framework,
    bundleId: bundleID + "GitHubService",
    dependencies: [
        .core(module: .GitHubServiceInterface),
        .core(module: .NetworkKit),
        .core(module: .Logger)
    ],
    settings: .core(),
    hasTest: true
)
