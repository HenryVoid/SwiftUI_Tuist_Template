import Foundation
import ProjectDescription

public enum Module {
    case feature(Feature)
    case core(Core)
    case design(Design)
}

// MARK: Feature
public extension Module {
    enum Feature: String, CaseIterable {
        case Auth
        case Main
        case Base
        case GitHubSearchMVVM
        case GitHubSearchTCA
        case GitHubSearchReactor
        case PerformanceDashboard
        
        public static let name: String = "Feature"
    }
}

// MARK: -  Core
public extension Module {
    enum Core: String, CaseIterable {
        case Entity
        case NetworkKit
        case Logger
        case Utility
        case CoreKit
        case CacheKit
        case AnalyticsKit
        case GitHubService
        case PerformanceMonitor
        
        public static let name: String = "Core"
    }
}

// MARK: - Core + Design
public extension Module {
    enum Design: String, CaseIterable {
        case DesignSystem
        
        public static let name: String = "DesignSystem"
    }
}
