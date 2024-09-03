import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "Utility",
    organizationName: organizationName,
    product: .staticLibrary,
    bundleId: bundleID + "Utility",
    dependencies: [],
    settings: .core()
)
