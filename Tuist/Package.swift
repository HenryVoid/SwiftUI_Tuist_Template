// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [:]
    )
#endif

let package = Package(
    name: "MyApp",
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", branch: "master"),
        .package(url: "https://github.com/kean/NukeUI", branch: "main"),
    ]
)
