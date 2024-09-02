import Foundation
import OSLog

public struct Log {
    public init(){}
    
    public enum LogLevel {
        case debug
        case info
        case network
        case error
        case custom(category: String)
        
        fileprivate var category: String {
            switch self {
            case .debug:
                return "🟡 DEBUG"
            case .info:
                return "🟠 INFO"
            case .network:
                return "🔵 NETWORK"
            case .error:
                return "🔴 ERROR"
            case .custom(let category):
                return "🟢 \(category)"
            }
        }
        
        fileprivate var osLog: OSLog {
            switch self {
            case .debug:
                return OSLog.debug
            case .info:
                return OSLog.info
            case .network:
                return OSLog.network
            case .error:
                return OSLog.error
            case .custom:
                return OSLog.debug
            }
        }
        
        fileprivate var osLogType: OSLogType {
            switch self {
            case .debug:
                return .debug
            case .info:
                return .info
            case .network:
                return .default
            case .error:
                return .error
            case .custom:
                return .debug
            }
        }
        
        
    }
    
    
    static func log(_ message: Any, _ arguments: [Any], level: LogLevel) {
        #if DEBUG
        let extraMessage: String = arguments.map({ String(describing: $0) }).joined(separator: " ")
        let logger = Logger(subsystem: OSLog.subsystem, category: level.category)
        let logMessage = "\(message) \(extraMessage)"
        switch level {
        case .debug,
                .custom:
            logger.debug("\(logMessage, privacy: .public)")
        case .info:
            logger.info("\(logMessage, privacy: .public)")
        case .network:
            logger.log("\(logMessage, privacy: .public)")
        case .error:
            logger.error("\(logMessage, privacy: .public)")
        }
        #endif
    }
}
