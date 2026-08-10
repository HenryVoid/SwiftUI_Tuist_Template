import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "NetworkKit",
    organizationName: organizationName,
    product: .staticLibrary,
    bundleId: bundleID + "NetworkKit",
    dependencies: [],
    settings: .core(),
    hasTest: true
)
