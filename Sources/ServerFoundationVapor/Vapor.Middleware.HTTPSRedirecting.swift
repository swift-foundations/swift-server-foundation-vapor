//
//  HTTPSRedirectMiddleware.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 17/07/2023.
//

import ServerFoundation
import Vapor

extension Vapor.Middlewares {
    public struct HTTPSRedirecting: AsyncMiddleware {
        public let on: Bool

        public init(on: Bool) {
            self.on = on
        }

        public func respond(to request: Request, chainingTo next: AsyncResponder) async throws
            -> Response
        {
            guard on else { return try await next.respond(to: request) }

            let host = request.headers.first(name: .host)
            let xForwardedProto = request.headers.first(name: HTTPHeaders.Name.xForwardedProto)
            let currentScheme = xForwardedProto ?? request.url.scheme ?? "http"

            request.logger.debug(
                "HTTPS check - Host: \(host ?? "none"), X-Forwarded-Proto: \(xForwardedProto ?? "none"), URL Scheme: \(request.url.scheme ?? "none")"
            )

            guard currentScheme == "https" else {
                guard let host = host else {
                    request.logger.warning("HTTPS redirect failed - missing Host header")
                    throw Abort(.badRequest, reason: "Missing Host header")
                }

                var httpsURL = request.url
                httpsURL.scheme = "https"

                request.logger.info(
                    "Redirecting to HTTPS - From: \(currentScheme)://\(host) To: \(httpsURL.string)"
                )

                return request.redirect(to: httpsURL.string, redirectType: .permanent)
            }

            let response = try await next.respond(to: request)
            response.headers.add(
                name: "Strict-Transport-Security",
                value: "max-age=31536000; includeSubDomains; preload"
            )

            request.logger.debug("HTTPS validation passed for: \(host ?? "unknown host")")

            return response
        }
    }
}
