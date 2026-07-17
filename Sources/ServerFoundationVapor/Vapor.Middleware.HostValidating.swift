//
//  HostValidationMiddleware.swift
//  ServerFoundationVapor
//
//  Created by Claude on 31/07/2025.
//

import Logging
import ServerFoundation
import Vapor

extension Vapor.Middlewares {
    public struct HostValidating: AsyncMiddleware {
        private let allowedHosts: [String]
        private let logger: Logger

        public init(allowedHosts: [String], logger: Logger) {
            self.allowedHosts = allowedHosts
            self.logger = logger
        }

        public func respond(to request: Vapor.Request, chainingTo next: any Vapor.AsyncResponder)
            async throws -> Vapor.Response
        {

            guard let currentHostWithPort = request.headers.first(name: .host) else {
                throw Abort(.forbidden, reason: "Missing host header")
            }

            let currentHost =
                currentHostWithPort.split(separator: ":").first.map(String.init)
                ?? currentHostWithPort

            let allowedHostsSet = Set(allowedHosts)

            guard allowedHostsSet.contains(currentHost) else {
                logger.warning("Request from unauthorized host: \(currentHost)")
                throw Abort(.forbidden, reason: "Host not allowed")
            }

            return try await next.respond(to: request)
        }
    }

}
