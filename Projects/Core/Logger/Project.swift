import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "Logger",
    organizationName: organizationName,
    product: .framework,
    bundleId: bundleID + "Logger",
    dependencies: [],
    settings: .core(),
    hasTest: true
)
