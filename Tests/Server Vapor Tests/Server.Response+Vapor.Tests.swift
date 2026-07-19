import Foundation
import NIOHTTP1
import enum Server.Server
import Server_Vapor
import class Vapor.Application
import class Vapor.Request
import class Vapor.Response
import XCTest

final class ServerResponseVaporTests: XCTestCase {
    private var application: Application!

    override func setUp() async throws {
        application = try await Application.make(.testing)
    }

    override func tearDown() async throws {
        try await application.asyncShutdown()
    }

    func testRedirectConversionPreservesVaporWireRepresentation() {
        let location =
            "https://checkout.stripe.test/session/cs_123"
            + "?return=https%3A%2F%2Fapp.example%2Fa%2Fb"
            + "&note=%22caf%C3%A9%22"
        let explicit = Response(
            status: .seeOther,
            headers: ["Location": location]
        )
        let request = Request(
            application: application,
            method: .POST,
            on: application.eventLoopGroup.next()
        )
        let requestRedirect = request.redirect(to: location)
        let converted = Response(Server.Response.redirect(to: location))
        let responses = [explicit, requestRedirect, converted]

        for response in responses {
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.status.code, 303)
            XCTAssertEqual(response.headers.first(name: "Location"), location)
            XCTAssertEqual(response.headers.first(name: "Content-Length"), "0")
            XCTAssertEqual(response.body.data.map(Array.init) ?? [], [])
            XCTAssertEqual(response.body.count, 0)
        }

        XCTAssertEqual(headers(requestRedirect), headers(explicit))
        XCTAssertEqual(headers(converted), headers(explicit))
    }

    private func headers(_ response: Response) -> [String] {
        response.headers
            .map { "\($0.name.lowercased()):\($0.value)" }
            .sorted()
    }
}
