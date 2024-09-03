import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "Base",
    organizationName: organizationName,
    product: .framework,
    bundleId: bundleID + "Base",
    dependencies: [
        .core(module: .NetworkKit),
        .core(module: .Logger),
        .core(module: .Entity),
        .core(module: .Utility),
        .design(module: .DesignSystem),
    ],
    settings: .base("Base"),
    hasTest: false
)
