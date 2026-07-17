//
//  CanonicalRedirectMiddleware.swift
//  ServerFoundationVapor
//
//  Created by Claude on 31/07/2025.
//

import Logging
import ServerFoundation
import Vapor

extension Vapor.Middlewares {
    public struct CanonicalRedirecting: AsyncMiddleware {
        private let canonicalHost: String
        private let baseUrl: URL
        private let logger: Logger

        public init(canonicalHost: String, baseUrl: URL, logger: Logger) {
            self.canonicalHost = canonicalHost
            self.baseUrl = baseUrl
            self.logger = logger
        }

        public func respond(to request: Vapor.Request, chainingTo next: any Vapor.AsyncResponder)
            async throws -> Vapor.Response
        {

            guard let currentHostWithPort = request.headers.first(name: .host) else {
                return try await next.respond(to: request)
            }

            if currentHostWithPort != canonicalHost {
                if let requestURL = URL(string: request.url.string) {
                    let canonicalURL = try URL.canonical(
                        url: requestURL,
                        canonicalHost: canonicalHost
                    )
                    return request.redirect(
                        to: canonicalURL.absoluteString,
                        redirectType: .permanent
                    )
                } else {
                    logger.error("Failed to create canonical URL from: \(request.url.string)")
                }
            }

            return try await next.respond(to: request)
        }
    }

}
