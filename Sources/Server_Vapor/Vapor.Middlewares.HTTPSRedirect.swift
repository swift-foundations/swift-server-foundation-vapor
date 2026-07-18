import HTTP_Redirect
import Vapor

extension Vapor.Middlewares {
    public struct HTTPSRedirect: AsyncMiddleware {
        private let adapter: ServerMiddleware

        public init(on: Bool) {
            self.adapter = .init(Redirect.HTTPS(on: on))
        }

        public func respond(to request: Vapor.Request, chainingTo next: Vapor.AsyncResponder)
            async throws -> Vapor.Response
        {
            try await adapter.respond(to: request, chainingTo: next)
        }
    }
}
