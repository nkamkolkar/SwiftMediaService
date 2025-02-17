//
//  MediaServer.swift
//  SwiftMediaService
//
//  Created by Neelesh Kamkolkar on 2/15/25.
//


import Vapor

/// Configures and starts the Vapor-based HTTP server for media storage and streaming.
///
struct MediaServer {
    
    static func start() throws {
        
        
        var env = try Environment.detect()
        let app = Application(env)
        defer { app.shutdown() }
        
        JWTConfig.setupSigners(app: app)
        try routes.configureRoutes(app)
        try configure(app)
       
        
        // HTTPS Configuration (Self-Signed Cert Placeholder)
        if let tlsConfig = try? TLSConfiguration.makeServerConfiguration(
            certificateChain: [],
            privateKey: .file("certs/key.pem")
        ) {
            //app.http.server.configuration.tlsConfiguration = tlsConfig
        }
        
        let host = "0.0.0.0"
        let port = 8080
        AppLogger.shared.logInfo("Starting media server at https://\(host):\(port)")
       
        try app.run()
    }
    
    private static func configure(_ app: Application) throws {
        // Set maximum request body size for uploads
        app.routes.defaultMaxBodySize = "100mb"
        
        // Register middleware
        app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
        app.middleware.use(CORSMiddleware())
        
        //Add migrations to FluentDB
        //app.migrations.add(CreateUserMigration())
        app.logger.logLevel = .debug
        
        try StorageService.configure(app)
        
    }
   
}

//Main Function
do{
    let ms = MediaServer()
    try MediaServer.start()
}
