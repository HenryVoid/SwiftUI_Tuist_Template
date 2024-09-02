import Foundation

public extension Log {
    static func debug(_ message: Any, _ arguments: Any...) {
        log(message, arguments, level: .debug)
    }
    
    static func info(_ message: Any, _ arguments: Any...) {
        log(message, arguments, level: .info)
    }
    
    static func network(_ message: Any, _ arguments: Any...) {
        log(message, arguments, level: .network)
    }
    
    static func error(_ message: Any, _ arguments: Any...) {
        log(message, arguments, level: .error)
    }

    static func custom(category: String, _ message: Any, _ arguments: Any...) {
        log(message, arguments, level: .custom(category: category))
    }
}
