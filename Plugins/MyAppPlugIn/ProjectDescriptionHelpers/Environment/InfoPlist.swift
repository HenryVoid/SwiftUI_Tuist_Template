import Foundation
import ProjectDescription

public let infoPlist: [String: Plist.Value] = [
    "CFBundleShortVersionString": .string(marketingNumber),
    "CFBundleVersion": .string(buildNumber),
    "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait"],
    "UILaunchScreen": [:],
    "UIUserInterfaceStyle": "Light",
    "BASE_URL": "${BASE_URL}",
    "CFBundleURLTypes": [[
        "CFBundleTypeRole": "Editor",
        "CFBundleURLSchemes": [.string(bundleID)]
    ]]
]
