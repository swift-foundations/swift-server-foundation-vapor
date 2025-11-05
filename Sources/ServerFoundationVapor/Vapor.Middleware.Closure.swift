//
//  Middlewares.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 05-01-2024.
//

import Vapor

extension Vapor.Middlewares {
    public struct Closure: AsyncMiddleware {
        public let respond:
            @Sendable (_ request: Vapor.Request, _ next: Vapor.AsyncResponder) async throws ->
                Vapor.Response
        public func respond(to request: Vapor.Request, chainingTo next: Vapor.AsyncResponder)
            async throws -> Vapor.Response
        {
            try await respond(request, next)
        }
    }

    public mutating func use(
        at position: Middlewares.Position = .end,
        _ closure:
            @Sendable @escaping (_ request: Vapor.Request, _ next: Vapor.AsyncResponder)
            async throws -> Vapor.Response
    ) {
        self.use(Closure(respond: closure), at: position)
    }
}
