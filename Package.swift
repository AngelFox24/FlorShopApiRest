// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "FlorShopCore",
    platforms: [
        .macOS(.v15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        // 🐘 Fluent driver for Postgres.
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.8.0"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        // 🔵 Para generar tokens
        .package(url: "https://github.com/vapor/jwt.git", exact: "5.1.2"),
        // 🔵 Valkey Swift
        .package(url: "https://github.com/valkey-io/valkey-swift.git", from: "1.3.2"),
        // 🔵 Valkey Vapor
        .package(url: "https://github.com/vapor-community/valkey.git", from: "1.2.0"),
        // 🔵 Extension para validar FlorShopAuth
//        .package(url: "https://github.com/AngelFox24/florshop-auth-client.git", exact: "0.0.6"),
        .package(path: "../florshop-auth-client"),
        // 🔵 Extension para Networking
//        .package(url: "https://github.com/AngelFox24/florshop-networking.git", exact: "0.0.6"),
        .package(path: "../florshop-networking"),
        // 🔵 Extension para Valkey Streams
//        .package(url: "https://github.com/AngelFox24/florshop-valkey.git", exact: "0.0.6"),
        .package(path: "../florshop-valkey"),
        // 🔵 Shared DTOs
//        .package(url: "https://github.com/AngelFox24/florshop-dtos.git", exact: "1.0.30")
        .package(path: "../florshop-dtos")
    ],
    targets: [
        .executableTarget(
            name: "FlorShopCore",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "FlorShopDTOs", package: "florshop-dtos"),
                .product(name: "FlorShopAuthClient", package: "florshop-auth-client"),
                .product(name: "FlorShopNetworking", package: "florshop-networking"),
                .product(name: "FlorShopValkey", package: "florshop-valkey"),
                .product(name: "Valkey", package: "valkey-swift"),
                .product(name: "VaporValkey", package: "valkey")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "FlorShopCoreTest",
            dependencies: [
                .target(name: "FlorShopCore"),
                .product(name: "VaporTesting", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        )
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }
