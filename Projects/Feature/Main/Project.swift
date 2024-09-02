import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "Main",
    organizationName: organizationName,
    product: .staticLibrary,
    bundleId: bundleID + "Main",
    dependencies: [
        .feature(module: .Base)
    ],
    settings: .base("Main"),
    hasTest: true,
    hasDemo: true
)
