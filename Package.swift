// swift-tools-version: 6.3.3

import PackageDescription

extension String {
    static let serverVapor: Self = "Server_Vapor"
}

extension Target.Dependency {
    static var serverVapor: Self { .target(name: .serverVapor) }
}

extension Target.Dependency {
    static var cookies: Self { .product(name: "HTTP Cookies", package: "swift-http-cookies") }
    static var favicon: Self { .product(name: "Favicon", package: "swift-favicon") }
    static var host: Self { .product(name: "HTTP Host", package: "swift-http-host") }
    static var metrics: Self { .product(name: "Metrics", package: "swift-metrics") }
    static var redirect: Self { .product(name: "HTTP Redirect", package: "swift-http-redirect") }
    static var server: Self { .product(name: "Server", package: "swift-server") }
    static var session: Self { .product(name: "HTTP Session", package: "swift-http-session") }
    static var throttling: Self { .product(name: "Throttling", package: "swift-throttling") }
    static var vapor: Self { .product(name: "Vapor", package: "vapor") }
}

let package = Package(
    name: "swift-server-vapor",
    platforms: [
        .macOS(.v26),
        .iOS(.v26)
    ],
    products: [
        .library(name: "Server Vapor", targets: [.serverVapor])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-foundations/swift-dependencies.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-http-cookies.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-http-host.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-http-redirect.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-http-session.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-metrics.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-server.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-throttling.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-favicon.git", branch: "main"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.102.1")
    ],
    targets: [
        .target(
            name: .serverVapor,
            dependencies: [
                .cookies,
                .product(name: "Dependencies", package: "swift-dependencies"),
                .host,
                .metrics,
                .redirect,
                .server,
                .session,
                .throttling,
                .vapor,
                .favicon
            ]
        )

    ],
    swiftLanguageModes: [.v6]
)
