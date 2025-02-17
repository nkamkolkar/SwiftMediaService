

import Fluent
import FluentPostgresDriver
import Vapor
import FluentSQLiteDriver


struct StorageService {
    static func configure(_ app: Application) throws {
        // Database configuration
        /**app.databases.use(.postgres(
        hostname: Environment.get("DB_HOST") ?? "localhost",
        username: Environment.get("DB_USER") ?? "postgres",
        password: Environment.get("DB_PASSWORD") ?? "password",
        database: Environment.get("DB_NAME") ?? "mediaservice_db"
    ), as: .psql)
        */
        app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
            
            
        // Add migrations
        app.migrations.add(CreateUser())
        
        // Run migrations
        try app.autoMigrate().wait()
    }
}


