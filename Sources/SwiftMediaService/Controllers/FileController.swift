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
        let maxVideoSize: Int64 = 100 * 1024 * 1024 // 100MB
        let maxImageSize: Int64 = 20 * 1024 * 1024 // 20MB
        let allowedVideoTypes = ["mp4", "mov", "avi"]
        let allowedImageTypes = ["jpeg", "png", "heic"]
        
        struct UploadResponse: Content {
            let filename: String
            let filePath: String
        }

        return req.body.collect().flatMapThrowing { body in
            guard let data = body, data.readableBytes > 0 else {
                throw Abort(.badRequest, reason: "No file uploaded.")
            }
            
            // Extract content type
            guard let contentType = req.headers.contentType?.description.lowercased() else {
                throw Abort(.unsupportedMediaType, reason: "Missing content type.")
            }
            
            // Extract filename from headers
            let originalFileName = req.headers.first(name: .contentDisposition)?
                .replacingOccurrences(of: "attachment; filename=", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\"", with: "") // Remove extra quotes
                ?? "uploadedFile"
                

            AppLogger.shared.logInfo("Original file name: \(originalFileName)")

            
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

            let baseDirectory = FilePathManager.shared.publicBaseDirectory.path
            // Determine storage path
            let uniqueFileName = FilePathManager.shared.getFilePath(for: originalFileName, captureDate: nil)
            
            // Generate a unique filename while preserving extension
            let finalFileName = "\(uniqueFileName).\(fileExtension)"
            AppLogger.shared.logInfo("finalFileName Path to \(finalFileName)")
            let fileURL = URL(string: finalFileName)
            AppLogger.shared.logInfo("Saving Path to \(String(describing: fileURL))")
            
       
            // Convert ByteBuffer to Data and write
            let fileData = Data(buffer: data) // Ensure `data` exists

            do {
                try fileData.write(to: fileURL!)
                //let response = UploadResponse(filename: finalFileName, filePath: fileURL.path)
                let response = UploadResponse(filename: finalFileName, filePath: fileURL!.path)
                return try Response(status: .ok, body: .init(data: JSONEncoder().encode(response)))
            } catch {
                throw Abort(.internalServerError, reason: "Failed to save file.")
            }
        }
    }

    /// Downloads a file from storage.
    func download(req: Request) throws -> Response {
        let fileName = req.parameters.get("filename")!
        let baseDirectory = FilePathManager.shared.publicBaseDirectory.path
        AppLogger.shared.logInfo("download: baseDirectory: \(baseDirectory) FileName: \(fileName)")
        
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
            AppLogger.shared.logInfo("Looking for file: \(fileURL.path)")
            
            if lastPathComponent == fileName {
                AppLogger.shared.logInfo("Found for file: \(fileURL.path)")
                return fileURL.path
            }
        }
        return nil
    }

    func listFiles(req: Request) throws -> [String] {
        let fileManager = FileManager.default
        let storagePath = FilePathManager.shared.publicBaseDirectory

        guard let files = try? fileManager.contentsOfDirectory(atPath: storagePath.path) else {
            throw Abort(.internalServerError, reason: "Failed to list files.")
        } 
        
        return files
    }

    
    func routes(_ app: Application) {
        let fileRoutes = app.grouped("files")
        fileRoutes.post("upload", use: upload)
        fileRoutes.get("download", ":filename", use: download)
        fileRoutes.get("", use: listFiles)
    }
}

