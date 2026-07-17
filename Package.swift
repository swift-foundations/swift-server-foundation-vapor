// swift-tools-version: 6.3.3

import Foundation
import PackageDescription

extension String {
    static let serverFoundationVapor: Self = "ServerFoundationVapor"
    static let serverFoundationVaporTesting: Self = "ServerFoundationVaporTestSupport"
}

extension Target.Dependency {
    static var serverFoundationVapor: Self { .target(name: .serverFoundationVapor) }
    static var serverFoundationVaporTesting: Self { .target(name: .serverFoundationVaporTesting) }
}

extension Target.Dependency {
    static var logging: Self { .product(name: "Logging", package: "swift-log") }
    static var serverFoundation: Self { .product(name: "ServerFoundation", package: "swift-server-foundation") }
    static var favicon: Self { .product(name: "Favicon", package: "swift-favicon") }
    static var vapor: Self { .product(name: "Vapor", package: "vapor") }
    static var urlRouting: Self { .product(name: "URLRouting", package: "swift-url-routing") }
    static var vaporTesting: Self { .product(name: "VaporTesting", package: "vapor") }
}

let package = Package(
    name: "swift-server-foundation-vapor",
    platforms: [
        .macOS(.v26),
        .iOS(.v26)
    ],
    products: [
        .library(name: .serverFoundationVapor, targets: [.serverFoundationVapor]),
        .library(name: .serverFoundationVaporTesting, targets: [.serverFoundationVaporTesting])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/swift-foundations/swift-favicon.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-server-foundation.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-url-routing.git", branch: "main"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.102.1")
    ],
    targets: [
        .target(
            name: .serverFoundationVapor,
            dependencies: [
                .logging,
                .serverFoundation,
                .vapor,
                .urlRouting,
                .favicon
            ]
        ),
        .target(
            name: .serverFoundationVaporTesting,
            dependencies: [
                .serverFoundationVapor,
                .vaporTesting
            ]
        ),
        .testTarget(
            name: "ServerFoundationVaporTests",
            dependencies: [
                .serverFoundationVapor,
                .serverFoundationVaporTesting,
                .vaporTesting
            ]
        )

    ],
    swiftLanguageModes: [.v6]
)
