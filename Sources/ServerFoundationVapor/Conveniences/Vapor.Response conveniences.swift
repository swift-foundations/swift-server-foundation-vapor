//
//  File.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 30-12-2023.
//

import ServerFoundation
import Vapor

// MARK: - JSON Response Helpers

private struct Empty: Codable {}
extension JSONEncoder {
    public static let prettyPrinter: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes, .prettyPrinted]
        return encoder
    }()
}

extension Response {
    // MARK: Primary JSON method for Encodable types
    public static func json<T: Encodable>(
        success: Bool,
        data: T? = nil,
        message: String? = nil,
        status: HTTPStatus = .ok,
        encoder: JSONEncoder = .prettyPrinter
    ) -> Response {
        let response = Envelope(success: success, data: data, message: message)
        do {
            let jsonData = try encoder.encode(response)

            return Response(
                status: status,
                headers: ["Content-Type": "application/json; charset=utf-8"],
                body: .init(data: jsonData)
            )
        } catch {
            return Response(
                status: .internalServerError,
                body: .init(string: "Failed to encode response")
            )
        }
    }

    // MARK: JSON method without data (maintains compatibility)
    public static func json(
        success: Bool,
        message: String,
        status: HTTPStatus = .ok,
        encoder: JSONEncoder = .prettyPrinter
    ) -> Response {
        return Response.json(
            success: success,
            data: Optional<Empty>.none,
            message: message,
            status: status,
            encoder: encoder
        )
    }

    // MARK: JSON method for dictionary data using AnyCodable
    public static func json(
        success: Bool,
        data: [String: Any]? = nil,
        message: String? = nil,
        encoder: JSONEncoder = JSONEncoder()
    ) throws -> Response {
        struct JSONResponse: Encodable {
            let success: Bool
            let data: AnyCodable?
            let message: String?
        }

        let response = JSONResponse(
            success: success,
            data: data.map { AnyCodable.dictionary($0.mapValues(AnyCodable.init)) },
            message: message
        )

        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(response)

        return Response(
            status: success ? .ok : .badRequest,
            headers: ["Content-Type": "application/json; charset=utf-8"],
            body: .init(data: jsonData)
        )
    }

    // MARK: Success convenience methods (maintains compatibility)
    public static func success<T: Codable>(
        _ success: Bool,
        data: T? = nil,
        message: String? = nil,
        status: HTTPStatus = .ok
    ) -> Response {
        return json(success: success, data: data, message: message, status: status)
    }

    public static func success(
        _ success: Bool,
        message: String? = nil,
        status: HTTPStatus = .ok
    ) -> Response {
        return json(success: success, data: Optional<Empty>.none, message: message, status: status)
    }
}

extension Response {
    public static func robots(
        disallows: String
    ) -> Response {
        Response(
            status: .ok,
            body: .init(
                stringLiteral: """
                    User-Agent: *
                    \(disallows)
                    """
            )
        )
    }
}

extension Response {
    // 1xx
    public static var `continue`: Response { .init(status: .`continue`) }
    public static var switchingProtocols: Response { .init(status: .switchingProtocols) }
    public static var processing: Response { .init(status: .processing) }
    // TODO: add '103: Early Hints' (requires bumping SemVer major).

    // 2xx
    public static var ok: Response { .init(status: .ok) }
    public static var created: Response { .init(status: .created) }
    public static var accepted: Response { .init(status: .accepted) }
    public static var nonAuthoritativeInformation: Response {
        .init(status: .nonAuthoritativeInformation)
    }
    public static var noContent: Response { .init(status: .noContent) }
    public static var resetContent: Response { .init(status: .resetContent) }
    public static var partialContent: Response { .init(status: .partialContent) }
    public static var multiStatus: Response { .init(status: .multiStatus) }
    public static var alreadyReported: Response { .init(status: .alreadyReported) }
    public static var imUsed: Response { .init(status: .imUsed) }

    // 3xx
    public static var multipleChoices: Response { .init(status: .multipleChoices) }
    public static var movedPermanently: Response { .init(status: .movedPermanently) }
    public static var found: Response { .init(status: .found) }
    public static var seeOther: Response { .init(status: .seeOther) }
    public static var notModified: Response { .init(status: .notModified) }
    public static var useProxy: Response { .init(status: .useProxy) }
    public static var temporaryRedirect: Response { .init(status: .temporaryRedirect) }
    public static var permanentRedirect: Response { .init(status: .permanentRedirect) }

    // 4xx
    public static var badRequest: Response { .init(status: .badRequest) }
    public static var unauthorized: Response { .init(status: .unauthorized) }
    public static var paymentRequired: Response { .init(status: .paymentRequired) }
    public static var forbidden: Response { .init(status: .forbidden) }
    public static var notFound: Response { .init(status: .notFound) }
    public static var methodNotAllowed: Response { .init(status: .methodNotAllowed) }
    public static var notAcceptable: Response { .init(status: .notAcceptable) }
    public static var proxyAuthenticationRequired: Response {
        .init(status: .proxyAuthenticationRequired)
    }
    public static var requestTimeout: Response { .init(status: .requestTimeout) }
    public static var conflict: Response { .init(status: .conflict) }
    public static var gone: Response { .init(status: .gone) }
    public static var lengthRequired: Response { .init(status: .lengthRequired) }
    public static var preconditionFailed: Response { .init(status: .preconditionFailed) }
    public static var payloadTooLarge: Response { .init(status: .payloadTooLarge) }
    public static var uriTooLong: Response { .init(status: .uriTooLong) }
    public static var unsupportedMediaType: Response { .init(status: .unsupportedMediaType) }
    public static var rangeNotSatisfiable: Response { .init(status: .rangeNotSatisfiable) }
    public static var expectationFailed: Response { .init(status: .expectationFailed) }
    public static var imATeapot: Response { .init(status: .imATeapot) }
    public static var misdirectedRequest: Response { .init(status: .misdirectedRequest) }
    public static var unprocessableEntity: Response { .init(status: .unprocessableEntity) }
    public static var locked: Response { .init(status: .locked) }
    public static var failedDependency: Response { .init(status: .failedDependency) }
    public static var upgradeRequired: Response { .init(status: .upgradeRequired) }
    public static var preconditionRequired: Response { .init(status: .preconditionRequired) }
    public static var tooManyRequests: Response { .init(status: .tooManyRequests) }
    public static var requestHeaderFieldsTooLarge: Response {
        .init(status: .requestHeaderFieldsTooLarge)
    }
    public static var unavailableForLegalReasons: Response {
        .init(status: .unavailableForLegalReasons)
    }

    // 5xx
    public static var internalServerError: Response { .init(status: .internalServerError) }
    public static var notImplemented: Response { .init(status: .notImplemented) }
    public static var badGateway: Response { .init(status: .badGateway) }
    public static var serviceUnavailable: Response { .init(status: .serviceUnavailable) }
    public static var gatewayTimeout: Response { .init(status: .gatewayTimeout) }
    public static var httpVersionNotSupported: Response { .init(status: .httpVersionNotSupported) }
    public static var variantAlsoNegotiates: Response { .init(status: .variantAlsoNegotiates) }
    public static var insufficientStorage: Response { .init(status: .insufficientStorage) }
    public static var loopDetected: Response { .init(status: .loopDetected) }
    public static var notExtended: Response { .init(status: .notExtended) }
    public static var networkAuthenticationRequired: Response {
        .init(status: .networkAuthenticationRequired)
    }
}

extension Vapor.Response {
    public func expire(
        cookies: [WritableKeyPath<HTTPCookies, HTTPCookies.Value?>]
    ) {
        @Dependency(\.request) var request
        guard let request else { return }

        cookies.forEach { cookiePath in
            if var cookie = request.cookies[keyPath: cookiePath] {
                cookie.expires = .distantPast
                self.cookies[keyPath: cookiePath] = cookie
            }
        }
    }
}

// MARK: - AnyCodable (private vendor)
// Heritage: minimal private re-expression of the community AnyCodable shape
// (Flight-School/AnyCodable lineage), sufficient for json(success:data:message:)
// only. Supervisor-approved 2026-07-12 (sprint ledger 14:15; no public surface).
// Pass-2 re-expression onto institute JSON: filed in the DECISIONS-pass2 queue.
private enum AnyCodable: Encodable {
    case null
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case array([AnyCodable])
    case dictionary([String: AnyCodable])

    init(_ value: Any) {
        switch value {
        case let v as Bool: self = .bool(v)
        case let v as Int: self = .int(v)
        case let v as Double: self = .double(v)
        case let v as String: self = .string(v)
        case let v as [Any]: self = .array(v.map(AnyCodable.init))
        case let v as [String: Any]: self = .dictionary(v.mapValues(AnyCodable.init))
        default: self = .null
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null: try container.encodeNil()
        case .bool(let v): try container.encode(v)
        case .int(let v): try container.encode(v)
        case .double(let v): try container.encode(v)
        case .string(let v): try container.encode(v)
        case .array(let v): try container.encode(v)
        case .dictionary(let v): try container.encode(v)
        }
    }
}
