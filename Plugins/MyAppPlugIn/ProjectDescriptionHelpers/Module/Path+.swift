import Foundation
import ProjectDescription

// MARK: Path + Feature
public extension Path {
    static var feature: Self {
        return .relativeToRoot("Projects/\(Module.Feature.name)")
    }
    
    static func feature(_ module: Module.Feature) -> Self {
        return .relativeToRoot("Projects/\(Module.Feature.name)/\(module.rawValue)")
    }
}

// MARK: Path + Core
public extension Path {
    static var core: Self {
        return .relativeToRoot("Projects/\(Module.Core.name)")
    }
    
    static func core(_ module: Module.Core) -> Self {
        return .relativeToRoot("Projects/\(Module.Core.name)/\(module.rawValue)")
    }
}

// MARK: Path + Domain

public extension Path {
    static var domain: Self {
        return .relativeToRoot("Projects/\(Module.Core.name)/\(Module.Domain.name)")
    }
    
    static func domain(_ module: Module.Domain) -> Self {
        return .relativeToRoot("Projects/\(Module.Core.name)/\(Module.Domain.name)/\(module.rawValue)")
    }
}


// MARK: Path + DesignSystem

public extension Path {
    static var design: Self {
        return .relativeToRoot("Projects/\(Module.Design.name)")
    }
    
    static func design(_ module: Module.Design) -> Self {
        return .relativeToRoot("Projects/\(module.rawValue)")
    }
}

// MARK: Path + Entity

public extension Path {
    static var entity: Self {
        return .relativeToRoot("Projects/\(Module.Core.name)/\(Module.Entity.name)")
    }
    
    static func entity(_ module: Module.Entity) -> Self {
        return .relativeToRoot("Projects/\(Module.Core.name)/\(Module.Entity.name)/\(module.rawValue)")
    }
}
