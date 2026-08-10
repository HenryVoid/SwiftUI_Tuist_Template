import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "GitHubServiceInterface",
    organizationName: organizationName,
    product: .staticLibrary,
    bundleId: bundleID + "GitHubServiceInterface",
    dependencies: [],
    settings: .core(),
    hasTest: true
)
