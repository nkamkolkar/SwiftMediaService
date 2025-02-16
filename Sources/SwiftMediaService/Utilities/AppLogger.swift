import Logging
import Foundation

/// Singleton Logger for the application
struct AppLogger {
    static let shared = AppLogger()
    private let logger: Logger
    
    private init() {
        logger = Logger(label: "com.swiftmediaservice.app")
        setupLogging()
    }
    
    private func setupLogging() {
        LoggingSystem.bootstrap { label in
            StreamLogHandler.standardOutput(label: label)
        }
    }
    
    func logInfo(_ message: String) {
        logger.info("\(message)")
    }
    
    func logWarning(_ message: String) {
        logger.warning("\(message)")
    }
    
    func logError(_ message: String) {
        logger.error("\(message)")
    }
    
    func logDebug(_ message: String) {
        logger.debug("\(message)")
    }
}

// Usage Example:
// AppLogger.shared.logInfo("Server started successfully")

