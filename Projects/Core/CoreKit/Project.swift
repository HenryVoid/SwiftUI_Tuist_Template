import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "CoreKit",
    organizationName: organizationName,
    product: .framework,
    bundleId: bundleID + "CoreKit",
    dependencies: [
        .core(module: .NetworkKit),
        .core(module: .Logger),
        .core(module: .Entity),
        .core(module: .Utility)
    ],
    settings: .core()
)
