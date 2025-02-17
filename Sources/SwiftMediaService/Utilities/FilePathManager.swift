import Foundation

/// Manages file paths and directory structures for media storage.
struct FilePathManager {
    static let shared = FilePathManager()
    private let baseDirectory: URL
    
    var publicBaseDirectory: URL { baseDirectory }  // Expose it safely
    
    private init() {
        let fileManager = FileManager.default
        let defaultBasePath = fileManager.homeDirectoryForCurrentUser.appendingPathComponent("MediaStorage")
        print("Checking if MediaStorage exists: \(defaultBasePath.path)")
        print("Home Directory: \(fileManager.homeDirectoryForCurrentUser.path)")
        
        if !fileManager.fileExists(atPath: defaultBasePath.path) {
            try? fileManager.createDirectory(at: defaultBasePath, withIntermediateDirectories: true)
            AppLogger.shared.logInfo("Created default media storage directory at \(defaultBasePath)")
        }
     

        self.baseDirectory = defaultBasePath
    }
    
    /// Generates a storage path based on the file's capture date or current date.
    func generateStoragePath(for date: Date) -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let relativePath = formatter.string(from: date)
        let fullPath = baseDirectory.appendingPathComponent(relativePath, isDirectory: true)
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: fullPath.path) {
            try? fileManager.createDirectory(at: fullPath, withIntermediateDirectories: true)
        }
        
        return fullPath
    }
    
    /// Generates a unique filename using a combination of sanitized original filename, timestamp, and UUID.
    func generateUniqueFilename(originalName: String) -> String {
        
        let sanitizedFilename = originalName.replacingOccurrences(of: "[^a-zA-Z0-9_.]", with: "", options: .regularExpression)
        let timestamp = Int(Date().timeIntervalSince1970)
        let uuid = UUID().uuidString.prefix(8)
        return "\(sanitizedFilename)_\(timestamp)_\(uuid)"
    }
    
    /// Returns the full path for storing a media file.
    func getFilePath(for originalName: String, captureDate: Date?) -> URL {
         let storagePath = generateStoragePath(for: captureDate ?? Date())
         let uniqueFilename = generateUniqueFilename(originalName: originalName)
        
         return storagePath.appendingPathComponent(uniqueFilename)
       
    }
    
}



