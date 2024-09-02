import Foundation
import ProjectDescription

// MARK: TargetDependency + Feature
public extension TargetDependency {
    static func feature(module: Module.Feature) -> Self {
        return .project(target: module.rawValue, path: .feature(module))
    }
}

// MARK: TargetDependency + Design
public extension TargetDependency {
    static func design(module: Module.Design) -> Self {
        return .project(target: module.rawValue, path: .design(module))
    }
}

// MARK: TargetDependency + Core
public extension TargetDependency {
    static func core(module: Module.Core) -> Self {
        return .project(target: module.rawValue, path: .core(module))
    }
}


// MARK: TargetDependency + Domain

public extension TargetDependency {
    static func domain(module: Module.Domain) -> Self {
        return .project(target: module.rawValue, path: .domain(module))
    }
}


// MARK: TargetDependency + Entity

public extension TargetDependency {
    static func entity(module: Module.Entity) -> Self {
        return .project(target: module.rawValue, path: .entity(module))
    }
}
