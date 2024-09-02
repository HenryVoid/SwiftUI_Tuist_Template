import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "Logger",
    organizationName: organizationName,
    product: .staticLibrary,
    bundleId: bundleID + "Logger",
    dependencies: [],
    settings: .core()
)
