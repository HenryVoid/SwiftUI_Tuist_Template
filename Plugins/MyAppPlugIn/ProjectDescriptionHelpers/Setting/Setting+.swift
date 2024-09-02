import Foundation
import ProjectDescription

extension Settings {
    public static let main: Settings = .settings(
        base: .init()
            .swiftCompilationMode(.wholemodule)
            .automaticCodeSigning(devTeam: devTeam)
            .currentProjectVersion(buildNumber)
            .marketingVersion(marketingNumber)
            .debugInformationFormat(.dwarfWithDsym),
        configurations: [
            .debug(name: .debug, xcconfig: .relativeToRoot("XCConfig/Debug.xcconfig")),
            .release(name: .release, xcconfig: .relativeToRoot("XCConfig/Release.xcconfig"))
        ]
    )
    
    public static func base(_ name: String) -> Settings {
        return .settings(
            base: .init()
                .marketingVersion(marketingNumber)
                .currentProjectVersion(buildNumber)
                .automaticCodeSigning(devTeam: devTeam)
                .debugInformationFormat(.dwarfWithDsym),
            configurations: [
                .debug(name: .debug, xcconfig: .relativeToRoot("XCConfig/Debug.xcconfig")),
                .release(name: .release, xcconfig: .relativeToRoot("XCConfig/Release.xcconfig"))
            ]
        )
    }
    
    public static func core() -> Settings {
        return .settings(
            base: .init()
                .marketingVersion(marketingNumber)
                .currentProjectVersion(buildNumber)
                .automaticCodeSigning(devTeam: devTeam)
                .debugInformationFormat(.dwarfWithDsym),
            configurations: [
                .debug(name: .debug, xcconfig: .relativeToRoot("XCConfig/Debug.xcconfig")),
                .release(name: .release, xcconfig: .relativeToRoot("XCConfig/Release.xcconfig"))
            ]
        )
    }
}
