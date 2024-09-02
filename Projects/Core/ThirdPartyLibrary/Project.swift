import Foundation
import ProjectDescription
import MyAppPlugIn

let project = Project.makeModule(
    name: "ThirdPartyLibrary",
    organizationName: organizationName,
    product: .framework,
    bundleId: bundleID + "ThirdPartyLibrary",
    dependencies: [
        .SPM.Alamofire,
        .SPM.NukeUI
    ],
    settings: .core()
)
