import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "GitHubSearchReactor",
    organizationName: organizationName,
    product: .framework,
    bundleId: bundleID + "GitHubSearchReactor",
    dependencies: [
        .core(module: .GitHubService),
        .core(module: .CoreKit),
        .core(module: .CacheKit),
        .core(module: .Logger),
        .core(module: .AnalyticsKit),
        .design(module: .DesignSystem),
        .external(name: "ReactorKit"),
        .external(name: "RxSwift"),
        .external(name: "RxCocoa")
    ],
    settings: .feature("GitHubSearchReactor"),
    hasTest: true,
    hasDemo: true
)

