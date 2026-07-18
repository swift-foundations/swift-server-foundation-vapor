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
    static var server: Self { .product(name: "Server", package: "swift-server") }
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
        .package(url: "https://github.com/swift-foundations/swift-server.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-favicon.git", branch: "main"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.102.1")
    ],
    targets: [
        .target(
            name: .serverVapor,
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .server,
                .vapor,
                .favicon
            ]
        )

    ],
    swiftLanguageModes: [.v6]
)
