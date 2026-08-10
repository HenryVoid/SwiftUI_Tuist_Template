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
    resources: nil,  // Resources 번들 생성 이슈로 임시 비활성화
    dependencies: [],
    settings: .core(),
    hasDemo: true
)
