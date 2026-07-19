private import enum NIOHTTP1.HTTPResponseStatus
import Server
import struct Vapor.Abort

extension Abort {
    public init(_ error: Server.Error) {
        switch error {
        case .notFound: self.init(HTTPResponseStatus.notFound)
        case .badRequest(let reason):
            self.init(HTTPResponseStatus.badRequest, reason: reason)
        case .unauthorized: self.init(HTTPResponseStatus.unauthorized)
        case .forbidden: self.init(HTTPResponseStatus.forbidden)
        case .payloadTooLarge: self.init(HTTPResponseStatus.payloadTooLarge)
        case .decoding(let value):
            self.init(HTTPResponseStatus.unprocessableEntity, reason: "Failed to decode \(value)")
        case .notImplemented(let reason):
            self.init(HTTPResponseStatus.notImplemented, reason: reason)
        case .encoding(let value):
            self.init(HTTPResponseStatus.internalServerError, reason: "Failed to encode \(value)")
        case .engine(let description):
            self.init(HTTPResponseStatus.internalServerError, reason: description)
        case .unavailable(let service):
            self.init(HTTPResponseStatus.serviceUnavailable, reason: service)
        case .internalError(let description):
            self.init(HTTPResponseStatus.internalServerError, reason: description)
        }
    }

    public static let requestUnavailable = Abort(
        .internalServerError,
        reason: "Request is unavailable"
    )
}

extension Server.Error {
    public init(_ abort: Abort) {
        switch abort.status {
        case .notFound: self = .notFound
        case .badRequest: self = .badRequest(abort.reason)
        case .unauthorized: self = .unauthorized
        case .forbidden: self = .forbidden
        case .payloadTooLarge: self = .payloadTooLarge
        case .unprocessableEntity: self = .decoding(abort.reason)
        case .notImplemented: self = .notImplemented(abort.reason)
        case .serviceUnavailable: self = .unavailable(abort.reason)
        default: self = .engine(abort.reason)
        }
    }
}
