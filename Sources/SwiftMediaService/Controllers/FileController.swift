// FileController.swift
// Created in collaboration with Claude & ChatGPT
// Author : Neelesh Kamkolkar



import Vapor
import UniformTypeIdentifiers // Required for MIME type detection



/// Handles media file uploads and retrieval.
struct FileController {
    
    /**
     upload a file to the media server. files can be only video or images
     */
    func upload(req: Request) throws -> EventLoopFuture<Response> {
        
        let maxVideoSize: Int64 = AppConfig.default.maxVideoSize // 100MB
        let maxImageSize: Int64 = AppConfig.default.maxImageSize // 20MB
        let allowedVideoTypes = AppConfig.default.allowedVideoExtensions
        let allowedImageTypes = AppConfig.default.allowedImageExtensions
        
        struct UploadResponse: Content {
            let filename: String
            let filePath: String
        }
        
        let payload =  try req.authenticatedUser()
        
        AppLogger.shared.logDebug("✅ upload Authenticated request from user: \(payload.username) (ID: \(payload.userID))")
        
        return req.body.collect().flatMapThrowing { body in
            guard let data = body, data.readableBytes > 0 else {
                throw Abort(.badRequest, reason: "No file uploaded.")
            }
            
            guard let filePart = req.body.data else {
                throw Abort(.badRequest, reason: "No file data found")
            }
            
            //If client passes this in header use it, else use a generic name.
            let filename = req.headers["X-Filename"].first ?? "\(UUID().uuidString).bin"
            
            
            // Save original final name from client
            let originalFileName = filename
            
            AppLogger.shared.logDebug("Client file name: \(originalFileName)")
            
            // Extract file extension correctly
            var fileExtension = URL(fileURLWithPath: originalFileName).pathExtension.lowercased()
            
            AppLogger.shared.logInfo("Extracted file extension from FileName: \(fileExtension)")
            
            // Fallback: Extract from Content-Type if needed
            if fileExtension.isEmpty, let contentType = req.headers.contentType?.description.lowercased() {
                fileExtension = contentType.components(separatedBy: "/").last ?? ""
                AppLogger.shared.logInfo("Using content type as extension: \(fileExtension)")
            }
            
            AppLogger.shared.logInfo("Extracted from ContentType: \(fileExtension)")
            
            // Validate file type
            let isValidVideo = allowedVideoTypes.contains(fileExtension)
            let isValidImage = allowedImageTypes.contains(fileExtension)
            
            AppLogger.shared.logInfo("Allowed video types: \(allowedVideoTypes.joined(separator: ", "))")
            AppLogger.shared.logInfo("Allowed image types: \(allowedImageTypes.joined(separator: ", "))")
            
            
            guard isValidVideo || isValidImage else {
                throw Abort(.unsupportedMediaType, reason: "Invalid file type.")
            }
            
            // Determine max file size based on type
            let maxSize = isValidVideo ? maxVideoSize : maxImageSize
            
            guard data.readableBytes <= maxSize else {
                throw Abort(.payloadTooLarge, reason: "File exceeds allowed size.")
            }

            // Determine storage path
            let uniqueFileURL = try FilePathManager.shared.getFilePath(for: originalFileName, captureDate: nil)
            
            //save the final path and URL
            let finalFileName = "\(uniqueFileURL)"
            let fileURL = uniqueFileURL
            AppLogger.shared.logInfo("Saving Path to \(String(describing: fileURL))")
            
            // Convert ByteBuffer to Data and write
            let fileData = Data(buffer: data) // Ensure `data` exists
            
            do {
                try fileData.write(to: fileURL)
            
                // Return a publicly accessible URL
                //let baseURL = req.application.http.server.configuration.hostname
                //let fileURL = "\(baseURL)/uploads/\(fileURL)"

                let baseURL = "http://127.0.0.1:8080"
                var response: UploadResponse
                
                //TODO Clean up the flow and simplify 
                if let relativePath = getRelativePath(from: finalFileName){
                    let finalURL = baseURL + relativePath
                    print(finalURL)  // Output: http://127.0.0.1:8080/Uploads/2025/02/17/GUID/myimg.jpg
                    AppLogger.shared.logInfo("Access URL: \(String(describing: finalURL))")
                    response = UploadResponse(filename: originalFileName, filePath: baseURL + relativePath)
                }else{
                    response = UploadResponse(filename: originalFileName, filePath: baseURL + "FileNotFound")
                }
                return try Response(status: .ok, body: .init(data: JSONEncoder().encode(response)))
            } catch {
                throw Abort(.internalServerError, reason: "Failed to save file.")
            }
        }
    }
    
    func getRelativePath(from fullPath: String) -> String? {
        let baseFolder = "/Uploads/"
        
        // Strip the "file://" prefix if present
        let sanitizedPath = fullPath.replacingOccurrences(of: "file://", with: "")
        
        AppLogger.shared.logDebug("FileController.getRelativePath: Finding \(baseFolder) in \(sanitizedPath)")
        
        if let range = sanitizedPath.range(of: baseFolder) {
            return String(sanitizedPath[range.lowerBound...])  // Extract everything after "/Uploads/"
        }
        
        return nil  // Return nil if "/Uploads/" is not found
    }


    
    
    
    /// Downloads a file from storage.
    func download(req: Request) throws -> Response {
        
        let fileName = req.parameters.get("filename")!
        
        AppLogger.shared.logInfo("FileController.download: downloading \(fileName)")
        
        //let baseDirectory = FilePathManager.shared.publicBaseDirectory.path
        let baseDirectory = FilePathManager.shared.getPublicDirectory()

        AppLogger.shared.logInfo("download: baseDirectory: \(baseDirectory) FileName: \(fileName)")
        
    
        let payload =  try req.authenticatedUser()
        
        AppLogger.shared.logInfo("✅ download Authenticated request from user: \(payload.username) (ID: \(payload.userID))")
        
        // Perform a recursive search
        guard let filePathString = findFileRecursively(baseDirectory: baseDirectory, fileName: fileName) else {
            AppLogger.shared.logWarning("File \(fileName) not found! Aborting")
            throw Abort(.notFound, reason: "File not found.")
        }
        
        let fileURL = URL(fileURLWithPath: filePathString)
        
        AppLogger.shared.logInfo("Serving file at path: \(fileURL.path)")
        let data = try Data(contentsOf: fileURL)
        let response = Response(body: .init(data: data))
        
        // Determine MIME type using UTType
        // Key Fixes Implemented:
        // 1. Replaced the missing FileExtensionClassifier with Apple's UTType for accurate MIME type detection, ensuring correct Content-Type headers.
        // 2. Changed baseDirectory to publicBaseDirectory in FilePathManager to resolve private access issues when retrieving file paths.
        // 3. Fixed missing arguments in HTTPMediaType initialization by using UTType(filenameExtension:) to infer MIME types properly.
        let fileExtension = fileURL.pathExtension
        let mimeType = UTType(filenameExtension: fileExtension)?.preferredMIMEType ?? "application/octet-stream"
        response.headers.replaceOrAdd(name: .contentType, value: mimeType)
        
        
        // Set Content-Disposition to suggest download
        response.headers.add(name: .contentDisposition, value: "attachment; filename=\"\(fileName)\"")
        
        
        return response
    }
    
    /// Recursively searches for a file in the given directory.
    private func findFileRecursively(baseDirectory: String, fileName: String) -> String? {
        let fileManager = FileManager.default
        let baseURL = URL(fileURLWithPath: baseDirectory)
        
        guard let enumerator = fileManager.enumerator(at: baseURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles], errorHandler: nil) else {
            return nil
        }
        
        for case let fileURL as URL in enumerator {
            let lastPathComponent = fileURL.lastPathComponent
            AppLogger.shared.logDebug("Looking for file: \(fileURL.path)")
            
            if lastPathComponent == fileName {
                AppLogger.shared.logInfo("Found for file: \(fileURL.path)")
                return fileURL.path
            }
        }
        return nil
    }
    
    func listFiles(req: Request) throws -> [String] {
        let fileManager = FileManager.default
        let storagePath = FilePathManager.shared.getPublicDirectory()
        
        let payload =  try req.authenticatedUser()
        
        AppLogger.shared.logInfo("✅ List files Authenticated request from user: \(payload.username) (ID: \(payload.userID))")
        
        guard let files = try? fileManager.contentsOfDirectory(atPath: storagePath) else {
            throw Abort(.internalServerError, reason: "Failed to list files.")
        }
        
        return files
    }
    
    
    func routes(_ app: Application) {
        AppLogger.shared.logInfo("FileController.getRelativePath: Setting up routes and Middlewares...")
        
        let authMiddleware = JWTMiddleware() // Use JWTMiddleware for authentication
        
        let protected = app.grouped(authMiddleware)
        
        AppLogger.shared.logInfo("Configuring routes...")  // Add this for debugging
        app.get("health") { req in
            AppLogger.shared.logInfo("Media server is healthy and running...")
            return "Media server is healthy and running..."
        }
        
        //let protected = app.grouped(User.authenticator(), User.guardMiddleware())
        // Protected routes
        protected.post("upload", use: upload)
        protected.get("download", ":filename", use: download)
        protected.get("files", use: listFiles)
        
        app.get("Uploads", "**") { req async throws -> Response in
            let relativePath = req.parameters.getCatchall().joined(separator: "/")
            let fullPath = FilePathManager.shared.getPublicDirectory() + "/" + relativePath

            return req.fileio.streamFile(at: fullPath)
        }

    }
}


//Create a helper function to test for authenticated user each time.
extension Request {
    func authenticatedUser() throws -> TokenPayload {
        print("FileController.request.authenticatedUser() called")
        guard let payload = self.auth.get(TokenPayload.self) else {
            throw Abort(.unauthorized, reason: "User not authenticated.")
        }
        AppLogger.shared.logInfo("FileController.request.authenticatedUser() user \(payload.username) authenticated.")
        return payload
    }
}
