// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SwiftMediaService",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "SwiftMediaService", targets: ["SwiftMediaService"]),
    ],
    dependencies: [
        // Essential networking and web framework
        .package(url: "https://github.com/vapor/vapor.git", from: "4.83.1"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0"),
    
        
        // OpenAPI support
        .package(url: "https://github.com/apple/swift-openapi-generator", .upToNextMinor(from: "0.1.0")),
        .package(url: "https://github.com/apple/swift-openapi-runtime", .upToNextMinor(from: "0.1.0")),
        .package(url: "https://github.com/swift-server/swift-openapi-vapor", .upToNextMinor(from: "0.1.0")),
        
        //For User Registration and BCrypt encryption
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),

        
        // For working with files and media
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "SwiftMediaService",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIVapor", package: "swift-openapi-vapor"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "Fluent", package: "fluent"),
                .product(name:  "FluentPostgresDriver", package: "fluent-postgres-driver"), // Change to FluentSQLiteDriver if using SQLite
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),

                "Files"
            ],

            path: "Sources/SwiftMediaService",
            resources: [
                            .process("Config/openapi.yaml") // <-- Add this line
            ]
        ),
        .testTarget(
            name: "SwiftMediaServiceTests",
            dependencies: ["SwiftMediaService"],
            path: "Tests/SwiftMediaServiceTests"),
    ]
)
