import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "GitHubServiceInterface",
    organizationName: organizationName,
    product: .framework,
    bundleId: bundleID + "GitHubServiceInterface",
    dependencies: [],
    settings: .core(),
    hasTest: true
)
