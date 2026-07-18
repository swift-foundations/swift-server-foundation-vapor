import NIOHTTP1
import enum Server.Server
import Server_Vapor
import struct Vapor.Abort
import XCTest

final class AbortServerErrorTests: XCTestCase {
    func testMapping() {
        let cases: [(Server.Error, HTTPResponseStatus, String)] = [
            (.payloadTooLarge, .payloadTooLarge, HTTPResponseStatus.payloadTooLarge.reasonPhrase),
            (.notFound, .notFound, HTTPResponseStatus.notFound.reasonPhrase),
            (.badRequest("Malformed request"), .badRequest, "Malformed request"),
            (.unauthorized, .unauthorized, HTTPResponseStatus.unauthorized.reasonPhrase),
            (.forbidden, .forbidden, HTTPResponseStatus.forbidden.reasonPhrase),
            (.decoding("Signup"), .unprocessableEntity, "Failed to decode Signup"),
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
}
