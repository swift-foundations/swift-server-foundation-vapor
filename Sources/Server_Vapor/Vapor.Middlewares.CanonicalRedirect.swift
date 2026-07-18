import HTTP_Redirect
import Vapor

extension Vapor.Middlewares {
    public struct CanonicalRedirect: AsyncMiddleware {
        private let adapter: ServerMiddleware

        public init(host: String) {
            self.adapter = .init(Redirect.Canonical(host: host))
        }

        public func respond(to request: Vapor.Request, chainingTo next: Vapor.AsyncResponder)
            async throws -> Vapor.Response
        {
            try await adapter.respond(to: request, chainingTo: next)
        }
    }
}
