import NIOHTTP1
import enum Server.Server
import Server_Vapor
import struct Vapor.Abort
import XCTest

final class AbortServerErrorTests: XCTestCase {
    func testMapping() {
        let notImplementedReason = "Not \"implemented\"\nNog niet: 🧪"
        let cases: [(Server.Error, HTTPResponseStatus, String)] = [
            (.payloadTooLarge, .payloadTooLarge, HTTPResponseStatus.payloadTooLarge.reasonPhrase),
            (.notFound, .notFound, HTTPResponseStatus.notFound.reasonPhrase),
            (.badRequest("Malformed request"), .badRequest, "Malformed request"),
            (.unauthorized, .unauthorized, HTTPResponseStatus.unauthorized.reasonPhrase),
            (.forbidden, .forbidden, HTTPResponseStatus.forbidden.reasonPhrase),
            (.decoding("Signup"), .unprocessableEntity, "Failed to decode Signup"),
            (.notImplemented(notImplementedReason), .notImplemented, notImplementedReason),
            (.encoding("Signup"), .internalServerError, "Failed to encode Signup"),
            (.engine("Transport failed"), .internalServerError, "Transport failed"),
            (.unavailable("Database"), .serviceUnavailable, "Database"),
            (.internalError("Unexpected state"), .internalServerError, "Unexpected state"),
        ]

        for (error, status, reason) in cases {
            let abort = Abort(error)

            XCTAssertEqual(abort.status, status)
            XCTAssertEqual(abort.reason, reason)
        }
    }

    func testNotImplementedRoundTripsInBothDirections() {
        let reason = "Not \"implemented\"\nNog niet: 🧪"

        let forwardAbort = Abort(Server.Error.notImplemented(reason))
        XCTAssertEqual(forwardAbort.status, .notImplemented)
        XCTAssertEqual(forwardAbort.status.code, 501)
        XCTAssertEqual(forwardAbort.reason, reason)

        let forwardError = Server.Error(forwardAbort)
        guard case .notImplemented(let forwardReason) = forwardError else {
            XCTFail("Expected Server.Error.notImplemented")
            return
        }
        XCTAssertEqual(forwardReason, reason)
        XCTAssertEqual(forwardError.status, .notImplemented)
        XCTAssertEqual(forwardError.message, reason)

        let reverseError = Server.Error(Abort(.notImplemented, reason: reason))
        guard case .notImplemented(let reverseReason) = reverseError else {
            XCTFail("Expected Server.Error.notImplemented")
            return
        }
        XCTAssertEqual(reverseReason, reason)
        XCTAssertEqual(reverseError.status, .notImplemented)
        XCTAssertEqual(reverseError.message, reason)

        let reverseAbort = Abort(reverseError)
        XCTAssertEqual(reverseAbort.status, .notImplemented)
        XCTAssertEqual(reverseAbort.status.code, 501)
        XCTAssertEqual(reverseAbort.reason, reason)
    }
}
