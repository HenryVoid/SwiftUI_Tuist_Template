import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "DesignSystem",
    organizationName: organizationName,
    product: .staticLibrary,
    bundleId: bundleID + "DesignSystem",
    infoPlist: .extendingDefault(with: [
        "UIAppFonts": [
//            "Pretendard-Bold.otf",
//            "Pretendard-Medium.otf",
//            "Pretendard-Regular.otf"
        ]
    ]),
    resources: ["Resources/**"],
    dependencies: [
        .core(module: .ThirdPartyLibrary)
    ],
    settings: .core(),
    hasDemo: true
)
