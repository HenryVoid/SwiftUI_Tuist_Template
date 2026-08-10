import Foundation
import ProjectDescription

extension Settings {
    public static let main: Settings = makeSettings(
        swiftCompilationMode: .wholemodule
    )

    public static func base(_ name: String) -> Settings {
        return makeSettings()
    }

    public static func core() -> Settings {
        return makeSettings()
    }

    public static func feature(_ name: String) -> Settings {
        return makeSettings()
    }

    private static func makeSettings(
        swiftCompilationMode: SwiftCompilationMode? = nil
    ) -> Settings {
        var base = SettingsDictionary()
            .marketingVersion(marketingNumber)
            .currentProjectVersion(buildNumber)
            .automaticCodeSigning(devTeam: devTeam)
            .debugInformationFormat(.dwarfWithDsym)

        if let swiftCompilationMode {
            base = base.swiftCompilationMode(swiftCompilationMode)
        }

        return .settings(
            base: base,
            configurations: [
                .debug(name: .debug, xcconfig: .relativeToRoot("XCConfig/Debug.xcconfig")),
                .release(name: .release, xcconfig: .relativeToRoot("XCConfig/Release.xcconfig"))
            ]
        )
    }
}
