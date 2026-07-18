import Server
import Vapor

extension Abort {
    public init(_ error: Server.Error) {
        switch error {
        case .notFound: self.init(.notFound)
        case .badRequest(let reason): self.init(.badRequest, reason: reason)
        case .unauthorized: self.init(.unauthorized)
        case .forbidden: self.init(.forbidden)
        case .payloadTooLarge: self.init(.payloadTooLarge)
        case .decoding(let value): self.init(.unprocessableEntity, reason: "Failed to decode \(value)")
        case .encoding(let value): self.init(.internalServerError, reason: "Failed to encode \(value)")
        case .engine(let description): self.init(.internalServerError, reason: description)
        case .unavailable(let service): self.init(.serviceUnavailable, reason: service)
        case .internalError(let description): self.init(.internalServerError, reason: description)
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
        case .badRequest: self = .badRequest(abort.reason ?? "")
        case .unauthorized: self = .unauthorized
        case .forbidden: self = .forbidden
        case .payloadTooLarge: self = .payloadTooLarge
        case .unprocessableEntity: self = .decoding(abort.reason ?? "value")
        case .serviceUnavailable: self = .unavailable(abort.reason ?? "service")
        default: self = .engine(abort.reason ?? "Vapor abort")
        }
    }
}
