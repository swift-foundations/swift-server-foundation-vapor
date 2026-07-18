public import Server
import class Vapor.Application

extension Server.Vapor {
    /// Sets the default request-body limit using Vapor's byte-count syntax.
    public static func body(max: String, on application: Application) {
        application.routes.defaultMaxBodySize = .init(stringLiteral: max)
    }
}
