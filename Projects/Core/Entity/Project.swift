import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "Entity",
    organizationName: organizationName,
    product: .staticLibrary,
    bundleId: bundleID + "Entity",
    dependencies: [],
    settings: .core()
)
