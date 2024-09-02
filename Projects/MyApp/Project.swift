import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: appName,
    organizationName: organizationName,
    product: .app,
    bundleId: bundleID,
    infoPlist: .extendingDefault(with: infoPlist),
    dependencies: [
        .feature(module: .Auth),
        .feature(module: .Main)
    ],
    settings: .main
//    entitlements: .file(path: .path("Entitlements/MyApp.entitlements"))
)


