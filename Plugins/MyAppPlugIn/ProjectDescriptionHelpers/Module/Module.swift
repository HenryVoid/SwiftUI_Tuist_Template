import Foundation
import ProjectDescription

public enum Module {
    case feature(Feature)
    case core(Core)
    case domain(Domain)
    case design(Design)
    case entity(Entity)
}

// MARK: Feature
public extension Module {
    enum Feature: String, CaseIterable {
        case Auth
        case Main
        case Base
        
        public static let name: String = "Feature"
    }
}

// MARK: -  Core
public extension Module {
    enum Core: String, CaseIterable {
        case Entity
        case NetworkKit
        case ThirdPartyLibrary
        case Logger
        case Utility
        
        case CoreKit
        
        public static let name: String = "Core"
    }
}

// MARK: -  Core + Domain
public extension Module {
    enum Domain: String, CaseIterable {
        case API
        case Service
        
        public static let name: String = "Domain"
    }
}

// MARK: - Core + Design
public extension Module {
    enum Design: String, CaseIterable {
        case DesignSystem
        
        public static let name: String = "DesignSystem"
    }
}

// MARK: - Core + Entity
public extension Module {
    enum Entity: String, CaseIterable {
        case Entity
        
        public static let name: String = "Entity"
    }
}
