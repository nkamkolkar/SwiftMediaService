import Vapor

/// Configures and starts the Vapor-based HTTP server for media storage and streaming.
struct MediaServer {
    
    static func start() throws {
        let app = Application(try Environment.detect())
        defer { app.shutdown() }
        
        configure(app)
        
        AppLogger.shared.logInfo("Starting media server at https://0.0.0.0:8080")
        try app.run()
    }
    
    //Make public for tests to call this
    public static func configure(_ app: Application) {
        
        let corsConfig = CORSMiddleware.Configuration(
            allowedOrigin: .all,
            allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE],
            allowedHeaders: [.accept, .authorization, .contentType]
        )
        app.middleware.use(CORSMiddleware(configuration: corsConfig))

        
        JWTConfig.setupSigners(app: app)
        try? routes.configureRoutes(app)
        
        app.routes.defaultMaxBodySize = "100mb"
        
        //Set webservers public directory
        let outputDir = app.directory.publicDirectory + "Uploads"
        FilePathManager.shared.setPublicDirectory(outputDir)
        app.middleware.use(FileMiddleware(publicDirectory: FilePathManager.shared.getPublicDirectory()))
        
        AppLogger.shared.logInfo("Media Server Configure: Vapor Public Directory: \(app.directory.publicDirectory)")
        AppLogger.shared.logDebug("Media Server Configure: setting public directory to...: \(FilePathManager.shared.getPublicDirectory())")
        //print("Media Server Configure: Public Directory: \(app.directory.publicDirectory)")
        //print("Media Server Configure: Filemanager Directory: \(FilePathManager.shared.getPublicDirectory())")

        try? StorageService.configure(app)
    }
}
