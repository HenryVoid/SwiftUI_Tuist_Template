// swift-tools-version: 5.9
@preconcurrency import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [:]
    )
#endif

let package = Package(
    name: "MyApp",
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.12.0"),
        .package(url: "https://github.com/kean/NukeUI", from: "0.8.3"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.7.0"),
        .package(url: "https://github.com/ReactorKit/ReactorKit", from: "3.2.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift", from: "6.6.0")
    ]
)
