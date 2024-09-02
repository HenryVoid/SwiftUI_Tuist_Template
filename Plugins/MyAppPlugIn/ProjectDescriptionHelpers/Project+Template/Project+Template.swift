import ProjectDescription
import Foundation

public extension Project {
    static func makeModule(
        name: String,
        organizationName: String,
        destinations: Destinations = .iOS,
        product: Product,
        bundleId: String,
        deploymentTargets: DeploymentTargets? = .iOS("17.0"),
        infoPlist: InfoPlist = .default,
        sources: SourceFilesList = ["Sources/**"],
        resources: ResourceFileElements? = nil,
        dependencies: [TargetDependency] = [],
        settings: Settings,
        entitlements: Entitlements? = nil,
        package: [Package] = [],
        hasTest: Bool = false,
        hasDemo: Bool = false
    ) -> Project {
        let appTarget = Target.makeApp(
            name: name,
            destinations: destinations,
            product: product,
            bundleId: bundleId,
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            entitlements: entitlements,
            scripts: [],
            dependencies: dependencies
        )
        
        let testTarget = Target.makeTest(
            name: name,
            destinations: destinations,
            product: .unitTests,
            bundleId: bundleId,
            deploymentTargets: deploymentTargets,
            dependencies: dependencies
        )
        
        let demoTarget = Target.makeDemo(
            name: name,
            destinations: .iOS,
            product: .app,
            bundleId: bundleId,
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            entitlements: entitlements,
            scripts: []
        )
        
        let targets = [
            appTarget,
            hasTest ? testTarget : nil,
            hasDemo ? demoTarget : nil
        ].compactMap { $0 }
        
        let schemes: [Scheme] = [
            .makeScheme(target: .debug, name: name, hasTest),
            hasDemo ? .makeDemoScheme(target: .debug, name: name, hasTest) : nil
        ].compactMap { $0 }
        
        return Project(
            name: name,
            organizationName: organizationName,
            options: .options(),
            packages: package,
            settings: settings,
            targets: targets,
            schemes: schemes,
            additionalFiles: [.glob(pattern: .relativeToRoot("XCConfig/Shared.xcconfig"))]
        )
    }
}
