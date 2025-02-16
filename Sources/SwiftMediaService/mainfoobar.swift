// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import Vapor
import OpenAPIRuntime
import OpenAPIVapor



/**

 do {
     print("Main Starting Swift Media Service...")
     try MediaServer.start()
 } catch {
     fatalError("Failed to start the media server: \(error)")
 }

 
 let app = try Application(.detect())
 defer { app.shutdown() }
 
 // Configure middleware
 app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
 app.middleware.use(CORSMiddleware())
 
 // Basic route to verify the server is running
 app.get { req in
     return "Swift Media Service is running!"
 }
 
 
 */
