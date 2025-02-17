import Foundation

struct AppConfig {
    // Base storage path
    let storagePath: String
    
    // Allowed file extensions
    let allowedVideoExtensions: [String]
    let allowedImageExtensions: [String]
    
    // Maximum file sizes in bytes
    let maxVideoSize: Int64
    let maxImageSize: Int64
    
    // Default configuration
    static let `default` = AppConfig(
        storagePath: "\(FileManager.default.currentDirectoryPath)/storage",
        allowedVideoExtensions: ["mp4", "mov", "avi"],
        allowedImageExtensions: ["jpg", "jpeg", "png", "heic"],
        maxVideoSize: 100 * 1024 * 1024,  // 100MB
        maxImageSize: 20 * 1024 * 1024    // 20MB
    )
}
