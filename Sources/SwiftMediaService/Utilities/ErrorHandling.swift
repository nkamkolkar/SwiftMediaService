//
//  ErrorHandling.swift
//  SwiftMediaService
//
//  Created by Neelesh Kamkolkar on 2/15/25.
//

import Foundation

/// Defines common errors for the media service.
enum MediaServiceError: Error {
    case fileNotFound
    case invalidFileType
    case fileTooLarge
    case storageFailure(reason: String)
    case unauthorizedAccess
    case unknownError
    
    /// Provides user-friendly descriptions for errors.
    var localizedDescription: String {
        switch self {
        case .fileNotFound:
            return "The requested file could not be found."
        case .invalidFileType:
            return "The uploaded file type is not supported."
        case .fileTooLarge:
            return "The file exceeds the maximum allowed size."
        case .storageFailure(let reason):
            return "Failed to store the file: \(reason)"
        case .unauthorizedAccess:
            return "You do not have permission to access this resource."
        case .unknownError:
            return "An unknown error occurred. Please try again."
        }
    }
}

/// Utility for handling errors consistently.
struct ErrorHandler {
    static func handle(_ error: MediaServiceError) {
        AppLogger.shared.logError("Error: \(error.localizedDescription)")
    }
    
    static func handle(_ error: Error) {
        AppLogger.shared.logError("Unexpected Error: \(error.localizedDescription)")
    }
}

