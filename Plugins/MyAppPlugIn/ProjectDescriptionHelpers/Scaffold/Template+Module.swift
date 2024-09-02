import Foundation
import ProjectDescription

public enum ModuleTemplate {
    case feature(path: String)
    case core(path: String)
    case `default`(path: String)
    case baseView(path: String)
    case test(path: String)
    case demo(path: String)
    
    public var item: [Template.Item] {
        switch self {
        case .feature(let path):
            return [
                .file(
                    path: path + "/Project.swift",
                    templatePath: "../Stencil/feature.stencil"
                )
            ]
        case .core(let path):
            return [
                .file(
                    path: path + "/Project.swift",
                    templatePath: "../Stencil/core.stencil"
                )
            ]
        case .default(let path):
            return [
                .file(
                    path: path + "/Sources/file.swift",
                    templatePath: "../Stencil/file.stencil"
                )
            ]
        case .baseView(let path):
            return [
                .file(
                    path: path + "/Sources/Base.swift",
                    templatePath: "../Stencil/base.stencil"
                )
            ]
        case .test(let path):
            return [
                .file(
                    path: path + "/Tests/Sources/Test.swift",
                    templatePath: "../Stencil/test.stencil"
                )
            ]
        case .demo(let path):
            return [
                .file(
                    path: path + "/DemoApp/Sources/DemoApp.swift",
                    templatePath: "../Stencil/demo.stencil"
                ),
                .directory(
                    path: path + "/DemoApp/Resources",
                    sourcePath: "../Stencil/Assets.xcassets"
                ),
            ]
        }
    }
}
