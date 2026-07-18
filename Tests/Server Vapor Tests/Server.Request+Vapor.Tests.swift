import NIOCore
import NIOHTTP1
import enum Server.Server
import Server_Vapor
import struct Vapor.Abort
import class Vapor.Application
import class Vapor.Request
import XCTVapor
import XCTest

final class ServerRequestVaporTests: XCTestCase {
    private var application: Application!

    override func setUp() async throws {
        application = try await Application.make(.testing)
    }

    override func tearDown() async throws {
        try await application.asyncShutdown()
    }

    func testConversionPreservesRequestData() async throws {
        var body = ByteBufferAllocator().buffer(capacity: 4)
        body.writeBytes([0, 127, 128, 255])
        let request = Request(
            application: application,
            method: .POST,
            url: "/waiting-list/signup?ref=abc%201",
            headers: ["X-Trace": "request-value"],
            collectedBody: body,
            on: application.eventLoopGroup.next()
        )

        let converted = try await Server.Request(request)

        XCTAssertEqual(converted.method, .post)
        XCTAssertEqual(converted.path, ["waiting-list", "signup"])
        XCTAssertEqual(converted.query, "ref=abc%201")
        XCTAssertEqual(converted.headers.first("x-trace")?.rawValue, "request-value")
        XCTAssertEqual(converted.body, [0, 127, 128, 255])
    }

    func testTransportFailureMapsToTypedEngineError() async throws {
        application.on(.POST, "transport-failure", body: .stream) { request async -> String in
            do {
                _ = try await Server.Request(request)
                return "unexpected success"
            } catch {
                guard let error = error as? Server.Error else {
                    XCTFail("Expected Server.Error, got \(error)")
                    return "unexpected error: \(error)"
                }
                switch error {
                case .engine(let description):
                    return description
                default:
                    return "unexpected error: \(error.message)"
                }
            }
        }
        var body = ByteBufferAllocator().buffer(capacity: 20_000)
        body.writeBytes(Array(repeating: UInt8(0), count: 20_000))
        let expected = String(describing: Abort(HTTPResponseStatus.payloadTooLarge))

        try await application.testable(method: .running(port: 0)).test(
            .POST,
            "/transport-failure",
            body: body
        ) { response async in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(response.body.string, expected)
        }
    }
}
