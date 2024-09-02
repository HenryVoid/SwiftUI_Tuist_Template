import Foundation
import ProjectDescription
import MyAppPlugIn


let project = Project.makeModule(
    name: "Auth",
    organizationName: organizationName,
    product: .staticLibrary,
    bundleId: bundleID + "Auth",
    infoPlist: .extendingDefault(with: infoPlist),
    dependencies: [
        .feature(module: .Base)
    ],
    settings: .base("Auth"),
    hasTest: true,
    hasDemo: true
)
