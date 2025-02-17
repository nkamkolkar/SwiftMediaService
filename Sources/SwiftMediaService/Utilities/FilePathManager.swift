import Foundation

/// Manages file paths and directory structures for media storage.
struct FilePathManager {
    static let shared =  FilePathManager()
    private let baseDirectory: URL
    /// Base directory for internal storage (private)
    private var defaultBasePath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("MediaStorage")
    /// Base directory for public storage (served by Vapor, Requires Configuration)
    static private var publicBasePath : String = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Public/Uploads").absoluteString
    
    //app.directory.publicDirectory + "Uploads/"
    //static private let publicBasePath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Public/Uploads")
    
    //var publicBaseDirectory: URL { baseDirectory }  // Expose it safely
    private var basePath : URL { defaultBasePath }
    
    private init() {
        self.baseDirectory = self.defaultBasePath
    }
    
    /// Returns the full path for storing a media file.
    ///  Depending on where system is run either use a Publicly accessible folder for destination or privarte location.
    ///  Control public vs private with isPublic flag
    func getFilePath(for originalName: String, captureDate: Date?) throws -> URL {
        let uniqueFilename = try generateStoragePath(for: originalName, isPublic: true)
        return uniqueFilename
        
    }
    
    func setPublicDirectory(_ path: String) {
        FilePathManager.publicBasePath = path
    }
    
    func getPublicDirectory() -> String {
        return FilePathManager.publicBasePath
    }

    
    /// Ensures the directory exists
    private func ensureDirectoryExists(at path: URL) throws {
        if !FileManager.default.fileExists(atPath: path.path) {
            try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    /// Generates a unique storage path based on user ID or session
    func generateStoragePath(for filename: String, isPublic: Bool = false) throws -> URL {
        let basePath = getPublicDirectory().isEmpty ? self.basePath : URL(fileURLWithPath: getPublicDirectory())
        try ensureDirectoryExists(at: basePath)
        
        print("generateStoragePath2: basePath \(basePath)")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let relativePath = formatter.string(from: Date())
        let fullPath = basePath.appendingPathComponent(relativePath, isDirectory: true)
        
        print("generateStoragePath2: relativePath\(relativePath)")
        print("generateStoragePath2: fullPath\(fullPath)")
        // Unique directory structure (modify as needed)
        let uniqueFolder = UUID().uuidString
        let storagePath = fullPath.appendingPathComponent(uniqueFolder, isDirectory: true)
        
        print("generateStoragePath2: uniqueFolder  \(uniqueFolder)")
        print("generateStoragePath2: storagePath  \(storagePath)")
        try ensureDirectoryExists(at: storagePath)
        
        print("generateStoragePath2: finalPath  \(storagePath).\(filename)")
        return storagePath.appendingPathComponent(filename)
    }
    
    
   
    
}



