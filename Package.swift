// swift-tools-version: 6.3.3

import PackageDescription

extension String {
    static let serverVapor: Self = "Server_Vapor"
}

extension Target.Dependency {
    static var serverVapor: Self { .target(name: .serverVapor) }
}

extension Target.Dependency {
    static var favicon: Self { .product(name: "Favicon", package: "swift-favicon") }
    static var host: Self { .product(name: "HTTP Host", package: "swift-http-host") }
    static var httpStandard: Self {
        .product(name: "HTTP Standard", package: "swift-http-standard")
    }
    static var logging: Self { .product(name: "Logging", package: "swift-log") }
    static var metrics: Self { .product(name: "Metrics", package: "swift-metrics") }
    static var nioCore: Self { .product(name: "NIOCore", package: "swift-nio") }
    static var nioHTTP1: Self { .product(name: "NIOHTTP1", package: "swift-nio") }
    static var redirect: Self { .product(name: "HTTP Redirect", package: "swift-http-redirect") }
    static var server: Self { .product(name: "Server", package: "swift-server") }
    static var vapor: Self { .product(name: "Vapor", package: "vapor") }
    static var xctVapor: Self { .product(name: "XCTVapor", package: "vapor") }
}

let package = Package(
    name: "swift-server-vapor",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
    ],
    products: [
        .library(name: "Server Vapor", targets: [.serverVapor])
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-foundations/swift-dependencies.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-foundations/swift-server.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-favicon.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-http-host.git", branch: "main"),
        .package(
            url: "https://github.com/swift-foundations/swift-http-redirect.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-standards/swift-http-standard.git",
            branch: "main"
        ),
        .package(url: "https://github.com/apple/swift-metrics.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.4"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.81.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.102.1"),
    ],
    targets: [
        .target(
            name: .serverVapor,
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .server,
                .vapor,
                .favicon,
                .host,
                .httpStandard,
                .logging,
                .metrics,
                .nioHTTP1,
                .redirect,
            ]
        ),
        .testTarget(
            name: "Server Vapor Tests",
            dependencies: [
                .serverVapor,
                .server,
                .vapor,
                .nioCore,
                .nioHTTP1,
                .xctVapor,
            ]
        ),
        .testTarget(
            name: "Server Vapor Consumer Tests",
            dependencies: [
                .serverVapor,
                .server,
                .logging,
            ],
            swiftSettings: [
                .enableUpcomingFeature("MemberImportVisibility")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
