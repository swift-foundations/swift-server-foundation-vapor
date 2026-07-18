import Server
import Server_Vapor
import XCTest

import class Vapor.Application
import struct Vapor.AsyncBasicResponder
import struct Vapor.Middlewares
import class Vapor.Request
import class Vapor.Response

final class VaporRequestClassifiersTests: XCTestCase {
    private var application: Application!

    override func setUp() async throws {
        application = try await Application.make(.testing)
    }

    override func tearDown() async throws {
        try await application.asyncShutdown()
    }

    func testFormSubmissionClassifier() {
        let request = Request(
            application: application,
            method: .POST,
            headers: ["Content-Type": "application/x-www-form-urlencoded"],
            on: application.eventLoopGroup.next()
        )
        XCTAssertTrue(request.isFormSubmission)
        XCTAssertFalse(request.isAJAXRequest)
    }

    func testAJAXClassifierUsesHeaderAndPrimaryAccept() {
        let headerRequest = Request(
            application: application,
            headers: ["X-Requested-With": "XMLHttpRequest"],
            on: application.eventLoopGroup.next()
        )
        XCTAssertTrue(headerRequest.isAJAXRequest)

        let acceptRequest = Request(
            application: application,
            headers: ["Accept": "application/json, text/html"],
            on: application.eventLoopGroup.next()
        )
        XCTAssertTrue(acceptRequest.isAJAXRequest)
    }

    func testServerMiddlewarePreservesDownstreamBody() async throws {
        struct Passthrough: Server.Middleware {
            func intercept(
                _ request: Server.Request,
                next: Server.Responder
            ) async throws(Server.Error) -> Server.Response {
                try await next(request)
            }
        }

        let request = Request(
            application: application,
            method: .GET,
            url: "/status?ok=1",
            on: application.eventLoopGroup.next()
        )
        let adapter = Vapor.Middlewares.ServerMiddleware(Passthrough())
        let response = try await adapter.respond(
            to: request,
            chainingTo: AsyncBasicResponder { _ in
                Response(status: .ok, body: .init(string: "downstream"))
            }
        )
        XCTAssertEqual(response.body.string, "downstream")
    }

    func testCanonicalRedirectConvertsHeadersPathAndQuery() async throws {
        let request = Request(
            application: application,
            method: .GET,
            url: "/status?ok=1",
            headers: [
                "Host": "old.example",
                "X-Forwarded-Proto": "https",
            ],
            on: application.eventLoopGroup.next()
        )
        let middleware = Vapor.Middlewares.CanonicalRedirect(host: "canonical.example")
        let response = try await middleware.respond(
            to: request,
            chainingTo: AsyncBasicResponder { _ in Response(status: .ok) }
        )
        XCTAssertEqual(response.status.code, 301)
        XCTAssertEqual(
            response.headers.first(name: "Location"),
            "https://canonical.example/status?ok=1"
        )
    }
}
