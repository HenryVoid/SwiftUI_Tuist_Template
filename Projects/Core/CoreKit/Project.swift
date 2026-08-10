import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "CoreKit",
    organizationName: organizationName,
    product: .framework,
    bundleId: bundleID + "CoreKit",
    dependencies: [],
    settings: .core(),
    hasTest: true
)
