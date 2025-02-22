//
//  MediaCacheManager.swift
//  SwiftMediaClient
//
//  Created by Neelesh Kamkolkar on 2/21/25.
//
import Foundation

struct MediaCacheManager {
    let fileManager = FileManager.default
    let cacheDirectory: URL
    
    public static var shared = MediaCacheManager()
    
    private init() {
        let cachesDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.cacheDirectory = cachesDir.appendingPathComponent(APIConfig.mediaCache, isDirectory: true)

        // Create cache directory if it doesn't exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    /// Checks if a file is cached.
    public func isCached(url: URL) -> Bool {
        let cachedFilePath = cacheDirectory.appendingPathComponent(url.lastPathComponent).path
        return fileManager.fileExists(atPath: cachedFilePath)
    }

    /// Writes data to the cache.
    public func writeToCache(data: Data, url: URL) -> String {
        let cachedFilePath = cacheDirectory.appendingPathComponent(url.lastPathComponent)

        if isCached(url: url) {
            Swift.print("MediaCacheManager - File already cached at \(cachedFilePath)")
            return "File already cached"
        }

        do {
            try data.write(to: cachedFilePath)
            Swift.print("MediaCacheManager - Written to cache: \(cachedFilePath)")
            return "Written to cache: \(cachedFilePath)"
        } catch {
            Swift.print("MediaCacheManager - Failed to write to cache: \(error.localizedDescription)")
            return "Failed to write cache"
        }
    }
    
    /// **New Function**: Retrieves all cached media files.
    public func getAllCachedFiles() -> [URL] {
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            let supportedFiles = fileURLs.filter { isValidMediaFile($0) }
            
            Swift.print("MediaCacheManager - Found \(supportedFiles.count) media files in cache.")
            return supportedFiles
        } catch {
            Swift.print("MediaCacheManager - Failed to read cache directory: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Checks if a file is a supported media format.
    private func isValidMediaFile(_ url: URL) -> Bool {
        let supportedExtensions = ["jpg", "jpeg", "png", "mp4", "mov"]
        return supportedExtensions.contains(url.pathExtension.lowercased())
    }
}
