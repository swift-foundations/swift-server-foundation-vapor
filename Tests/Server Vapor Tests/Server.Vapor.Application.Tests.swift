import enum Server.Server
import Server_Vapor
import class Vapor.Application
import XCTest

final class ServerVaporApplicationTests: XCTestCase {
    private var application: Server.Vapor.Application!

    override func setUp() async throws {
        application = try await Server.Vapor.Application.make(.testing)
    }

    override func tearDown() async throws {
        try await application.asyncShutdown()
    }

    func testDirectoryReturnsConfiguredPublicDirectory() {
        application.directory.publicDirectory = "/marketing/public/"

        XCTAssertEqual(
            Server.Vapor.directory(of: application),
            "/marketing/public/"
        )
    }

    func testBodyAppliesVaporByteCountSyntax() {
        Server.Vapor.body(max: "1mb", on: application)

        XCTAssertEqual(application.routes.defaultMaxBodySize.value, 1 << 20)
    }
}
