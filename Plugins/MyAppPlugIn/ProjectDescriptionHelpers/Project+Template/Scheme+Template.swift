import ProjectDescription
import Foundation

extension Scheme {
    static func makeScheme(target: ConfigurationName, name: String, _ hasTest: Bool) -> Self {
        scheme(name: "\(name)",
               shared: true,
               buildAction: .buildAction(targets: ["\(name)"]),
               testAction: hasTest ? .targets(["\(name)Tests"],
                                              arguments: nil,
                                              configuration: target,
                                              options: .options(coverage: true)) : .none,
               runAction: .runAction(configuration: target),
               archiveAction: .archiveAction(configuration: target),
               profileAction: .profileAction(configuration: target),
               analyzeAction: .analyzeAction(configuration: target))
    }

    static func makeDemoScheme(target: ConfigurationName, name: String, _ hasTest: Bool) -> Self {
        scheme(name: "\(name)DemoApp",
               shared: true,
               buildAction: .buildAction(targets: ["\(name)DemoApp"]),
               testAction: hasTest ? .targets(["\(name)Tests"],
                                              arguments: nil,
                                              configuration: target,
                                              options: .options(coverage: true)) : .none,
               runAction: .runAction(configuration: target),
               archiveAction: .archiveAction(configuration: target),
               profileAction: .profileAction(configuration: target),
               analyzeAction: .analyzeAction(configuration: target))
    }
}
