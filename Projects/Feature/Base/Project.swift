import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "Base",
    organizationName: organizationName,
    product: .framework,
    bundleId: bundleID + "Base",
    dependencies: [
        .core(module: .CoreKit),
        .design(module: .DesignSystem),
    ],
    settings: .base("Base"),
    hasTest: false
)
