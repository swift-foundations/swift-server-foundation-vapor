import NIOHTTP1
import enum Server.Server
import Server_Vapor
import struct Vapor.Abort
import XCTest

final class AbortServerErrorTests: XCTestCase {
    func testMapping() {
        let notFoundReason = "Not \"found\"\nNiet gevonden: 🔍"
        let paymentRequiredReason = "Payment \"required\"\nBetaling vereist: 💳"
        let forbiddenReason = "Access \"forbidden\"\nGeen toegang: 🚫"
        let notImplementedReason = "Not \"implemented\"\nNog niet: 🧪"
        let cases: [(Server.Error, HTTPResponseStatus, String)] = [
            (.payloadTooLarge, .payloadTooLarge, HTTPResponseStatus.payloadTooLarge.reasonPhrase),
            (.notFound(notFoundReason), .notFound, notFoundReason),
            (.badRequest("Malformed request"), .badRequest, "Malformed request"),
            (.unauthorized, .unauthorized, HTTPResponseStatus.unauthorized.reasonPhrase),
            (.paymentRequired(paymentRequiredReason), .paymentRequired, paymentRequiredReason),
            (.forbidden(forbiddenReason), .forbidden, forbiddenReason),
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

    func testNotFoundRoundTripsInBothDirections() {
        let reason = "Not \"found\"\nNiet gevonden: 🔍"

        let forwardAbort = Abort(Server.Error.notFound(reason))
        XCTAssertEqual(forwardAbort.status, .notFound)
        XCTAssertEqual(forwardAbort.status.code, 404)
        XCTAssertEqual(forwardAbort.reason, reason)

        let forwardError = Server.Error(forwardAbort)
        guard case .notFound(let forwardReason) = forwardError else {
            XCTFail("Expected Server.Error.notFound")
            return
        }
        XCTAssertEqual(forwardReason, reason)
        XCTAssertEqual(forwardError.status, .notFound)
        XCTAssertEqual(forwardError.message, reason)

        let reverseError = Server.Error(Abort(.notFound, reason: reason))
        guard case .notFound(let reverseReason) = reverseError else {
            XCTFail("Expected Server.Error.notFound")
            return
        }
        XCTAssertEqual(reverseReason, reason)
        XCTAssertEqual(reverseError.status, .notFound)
        XCTAssertEqual(reverseError.message, reason)

        let reverseAbort = Abort(reverseError)
        XCTAssertEqual(reverseAbort.status, .notFound)
        XCTAssertEqual(reverseAbort.status.code, 404)
        XCTAssertEqual(reverseAbort.reason, reason)
    }

    func testPaymentRequiredRoundTripsInBothDirections() {
        let reason = "Payment \"required\"\nBetaling vereist: 💳"

        let forwardAbort = Abort(Server.Error.paymentRequired(reason))
        XCTAssertEqual(forwardAbort.status, .paymentRequired)
        XCTAssertEqual(forwardAbort.status.code, 402)
        XCTAssertEqual(forwardAbort.reason, reason)

        let forwardError = Server.Error(forwardAbort)
        guard case .paymentRequired(let forwardReason) = forwardError else {
            XCTFail("Expected Server.Error.paymentRequired")
            return
        }
        XCTAssertEqual(forwardReason, reason)
        XCTAssertEqual(forwardError.status, .paymentRequired)
        XCTAssertEqual(forwardError.message, reason)

        let reverseError = Server.Error(Abort(.paymentRequired, reason: reason))
        guard case .paymentRequired(let reverseReason) = reverseError else {
            XCTFail("Expected Server.Error.paymentRequired")
            return
        }
        XCTAssertEqual(reverseReason, reason)
        XCTAssertEqual(reverseError.status, .paymentRequired)
        XCTAssertEqual(reverseError.message, reason)

        let reverseAbort = Abort(reverseError)
        XCTAssertEqual(reverseAbort.status, .paymentRequired)
        XCTAssertEqual(reverseAbort.status.code, 402)
        XCTAssertEqual(reverseAbort.reason, reason)
    }

    func testForbiddenRoundTripsInBothDirections() {
        let reason = "Access \"forbidden\"\nGeen toegang: 🚫"

        let forwardAbort = Abort(Server.Error.forbidden(reason))
        XCTAssertEqual(forwardAbort.status, .forbidden)
        XCTAssertEqual(forwardAbort.status.code, 403)
        XCTAssertEqual(forwardAbort.reason, reason)

        let forwardError = Server.Error(forwardAbort)
        guard case .forbidden(let forwardReason) = forwardError else {
            XCTFail("Expected Server.Error.forbidden")
            return
        }
        XCTAssertEqual(forwardReason, reason)
        XCTAssertEqual(forwardError.status, .forbidden)
        XCTAssertEqual(forwardError.message, reason)

        let reverseError = Server.Error(Abort(.forbidden, reason: reason))
        guard case .forbidden(let reverseReason) = reverseError else {
            XCTFail("Expected Server.Error.forbidden")
            return
        }
        XCTAssertEqual(reverseReason, reason)
        XCTAssertEqual(reverseError.status, .forbidden)
        XCTAssertEqual(reverseError.message, reason)

        let reverseAbort = Abort(reverseError)
        XCTAssertEqual(reverseAbort.status, .forbidden)
        XCTAssertEqual(reverseAbort.status.code, 403)
        XCTAssertEqual(reverseAbort.reason, reason)
    }
}
