//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 19/12/2024.
//

import Foundation
import Throttling
import Vapor

extension Vapor.Middlewares {
    public typealias Ratelimiting<Key: Hashable & Sendable> = RateLimiter<Key>.Middleware
}

extension RateLimiter {
    /// Middleware for integrating with Vapor
    public struct Middleware: AsyncMiddleware {
        let rateLimiter: RateLimiter<Key>
        let getKey: @Sendable (Vapor.Request) throws -> Key
        let onRejected: (@Sendable (Vapor.Request, RateLimitResult) throws -> Vapor.Response)?

        public init(
            rateLimiter: RateLimiter<Key>,
            getKey: @Sendable @escaping (Vapor.Request) -> Key,
            onRejected: (@Sendable (Vapor.Request, RateLimitResult) -> Vapor.Response)?
        ) {
            self.rateLimiter = rateLimiter
            self.getKey = getKey
            self.onRejected = onRejected
        }

        public func respond(to request: Vapor.Request, chainingTo next: AsyncResponder) async throws
            -> Response
        {
            let key = try getKey(request)
            let result = await rateLimiter.checkLimit(key)

            guard result.isAllowed
            else {
                if let onRejected = onRejected { return try onRejected(request, result) }

                return Response(
                    status: .tooManyRequests,
                    headers: .init([
                        (
                            HTTPHeaders.Name.xRateLimitLimit.description,
                            "\(result.currentAttempts + result.remainingAttempts)"
                        ),
                        (
                            HTTPHeaders.Name.xRateLimitRemaining.description,
                            "\(result.remainingAttempts)"
                        ),
                        (
                            HTTPHeaders.Name.xRateLimitReset.description,
                            "\(result.nextAllowedAttempt?.timeIntervalSince1970 ?? 0)"
                        ),
                    ])
                )
            }

            let response = try await next.respond(to: request)

            response.headers.add(
                name: .xRateLimitRemaining,
                value: "\(result.remainingAttempts)"
            )
            return response
        }
    }
}
