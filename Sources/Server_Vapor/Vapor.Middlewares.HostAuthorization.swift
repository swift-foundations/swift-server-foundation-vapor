import HTTP_Host
import Logging
import Vapor

extension Vapor.Middlewares {
    public struct HostAuthorization: AsyncMiddleware {
        private let allowedHosts: HTTP_Host.Host.Allowlist
        private let logger: Logger

        public init(allowedHosts: [String], logger: Logger) {
            self.allowedHosts = .init(allowedHosts: allowedHosts)
            self.logger = logger
        }

        public func respond(to request: Vapor.Request, chainingTo next: Vapor.AsyncResponder)
            async throws -> Vapor.Response
        {
            do {
                guard try allowedHosts.authorize(request.headers.first(name: .host)) == .allowed
                else {
                    logger.warning("Request from unauthorized host")
                    throw Abort(.forbidden, reason: "Host not allowed")
                }
            } catch HTTP_Host.Host.Error.missing {
                logger.warning("Missing host header")
                throw Abort(.forbidden, reason: "Missing host header")
            } catch HTTP_Host.Host.Error.malformed {
                logger.warning("Malformed host header")
                throw Abort(.forbidden, reason: "Host not allowed")
            }
            return try await next.respond(to: request)
        }
    }
}
