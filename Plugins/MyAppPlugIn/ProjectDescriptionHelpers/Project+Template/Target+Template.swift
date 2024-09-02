import ProjectDescription
import Foundation

public extension Target {
    static func makeApp(
        name: String,
        destinations: Destinations = .iOS,
        product: Product,
        bundleId: String,
        deploymentTargets: DeploymentTargets? = .iOS("16.0"),
        infoPlist: InfoPlist = .default,
        sources: SourceFilesList = ["Sources/**"],
        resources: ResourceFileElements? = nil,
        entitlements: Entitlements? = nil,
        scripts: [TargetScript] = [],
        dependencies: [TargetDependency] = []
    ) -> Target {
        return Target.target(
            name: name,
            destinations: destinations,
            product: product,
            bundleId: bundleId,
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            entitlements: entitlements,
            scripts: scripts,
            dependencies: dependencies
        )
    }
    
    static func makeTest(
        name: String,
        destinations: Destinations = .iOS,
        product: Product,
        bundleId: String,
        deploymentTargets: DeploymentTargets? = .iOS("16.0"),
        infoPlist: InfoPlist = .default,
        sources: SourceFilesList = ["Tests/**"],
        resources: ResourceFileElements? = nil,
        entitlements: Entitlements? = nil,
        dependencies: [TargetDependency] = []
    ) -> Target {
        return Target.target(
            name: "\(name)Tests",
            destinations: destinations,
            product: product,
            bundleId: "\(bundleId).\(name)Tests",
            deploymentTargets: deploymentTargets,
            sources: sources,
            scripts: [],
            dependencies: [.target(name: "\(name)")]
        )
    }
    
    static func makeDemo(
        name: String,
        destinations: Destinations = .iOS,
        product: Product,
        bundleId: String,
        deploymentTargets: DeploymentTargets? = .iOS("16.0"),
        infoPlist: InfoPlist = .default,
        entitlements: Entitlements? = nil,
        scripts: [TargetScript] = []
    ) -> Target {
        return Target.target(
            name: "\(name)DemoApp",
            destinations: destinations,
            product: product,
            bundleId: "\(bundleId).\(name)DemoApp",
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: ["DemoApp/Sources/**"],
            resources: ["DemoApp/Resources/**"],
            entitlements: entitlements,
            scripts: scripts,
            dependencies: [.target(name: "\(name)")]
        )
    }
}
