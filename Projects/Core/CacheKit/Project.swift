import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "CacheKit",
    organizationName: organizationName,
    product: .staticLibrary,
    bundleId: bundleID + "CacheKit",
    dependencies: [
        .core(module: .Logger)
    ],
    settings: .core(),
    hasTest: true
)

