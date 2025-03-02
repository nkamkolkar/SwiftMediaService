//
//  SwiftMediaClientApp.swift
//  SwiftMediaClient
//
//  Created by Neelesh Kamkolkar on 2/18/25.
//
import Foundation

class DownloadService: ObservableObject {
    
    @Published var downloadStatus: String?
    static let shared = DownloadService()
    let serverURLBase: URL

    private init() {
        self.serverURLBase = URL(string: APIConfig.baseURL)!
    }

    /// Downloads a media file using the `/download` endpoint and caches it.
    func downloadMediaFile(fileName: String) async {
        print("DownloadService.downloadMediaFile - Getting AuthToken")

        // Fetch Auth Token
        guard let authToken = await AuthService.shared.getAuthToken() else {
            print("⚠️ No valid token found")
            await updateStatus("Download failed: No authentication token")
            return
        }

        // Convert fileName to a URL in the cache directory
        let cachedFileURL = MediaCacheManager.shared.cacheDirectory.appendingPathComponent(fileName)

        // Check if file is already cached
        if MediaCacheManager.shared.isCached(url: cachedFileURL) {
            print("DownloadService - File already cached: \(cachedFileURL.lastPathComponent)")
            await updateStatus("Loaded from cache: \(fileName)")
            return
        }

        // Construct URL
        guard let url = URL(string: "\(serverURLBase)/download/\(fileName)") else {
            print("DownloadService - Invalid URL provided")
            await updateStatus("Download failed: Invalid URL")
            return
        }

        print("DownloadService - Fetching from: \(url)")

        // Prepare request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        do {
            // Perform network request
            let (data, response) = try await URLSession.shared.data(for: request)

            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
                print("DownloadService - HTTP Error \(statusCode)")
                await updateStatus("Download failed: HTTP \(statusCode)")
                return
            }

            // Cache file locally using the URL path
            MediaCacheManager.shared.writeToCache(data: data, url: cachedFileURL)
            print("DownloadService - Downloaded and cached \(fileName)")
            await updateStatus("Download succeeded for file: \(fileName)")

        } catch {
            print("DownloadService - Download error: \(error.localizedDescription)")
            await updateStatus("Download failed: \(error.localizedDescription)")
        }
    }
    
    /// Updates download status safely on the main thread
    @MainActor
    private func updateStatus(_ message: String) {
        self.downloadStatus = message
    }
}
