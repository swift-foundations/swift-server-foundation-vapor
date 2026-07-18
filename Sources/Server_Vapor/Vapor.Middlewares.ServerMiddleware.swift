import Foundation
import HTTP_Standard
import Server

import struct Vapor.Abort
import protocol Vapor.AsyncMiddleware
import protocol Vapor.AsyncResponder
import struct Vapor.Middlewares
import class Vapor.Request
import class Vapor.Response

extension Vapor.Middlewares {
    /// Adapts one engine-free middleware at the Vapor transport boundary.
    public struct ServerMiddleware: AsyncMiddleware {
        private let middleware: any Server.Middleware

        public init(_ middleware: any Server.Middleware) {
            self.middleware = middleware
        }

        public func respond(to request: Vapor.Request, chainingTo next: any Vapor.AsyncResponder)
            async throws -> Vapor.Response
        {
            let serverRequest = try await Server.Request(request)
            let vaporRequest = request
            do {
                let responder: Server.Responder = { _ in
                    try await Self.response(chainingTo: next, for: vaporRequest)
                }
                let serverResponse = try await middleware.intercept(
                    serverRequest,
                    next: responder
                )
                return Vapor.Response(serverResponse)
            } catch {
                throw Abort(error)
            }
        }

        private static func response(
            chainingTo next: any Vapor.AsyncResponder,
            for request: Vapor.Request
        ) async throws(Server.Error) -> Server.Response {
            do {
                return try await Server.Response(
                    next.respond(to: request),
                    on: request
                )
            } catch let abort as Abort {
                throw Server.Error(abort)
            } catch {
                throw .engine(String(describing: error))
            }
        }
    }
}

extension Server.Request {
    fileprivate init(_ request: Vapor.Request) async throws {
        let url = URL(string: request.url.string)
        let path = url?.path.split(separator: "/").map(String.init) ?? []
        let query = url?.query
        let headers = HTTP.Headers(
            request.headers.map {
                HTTP.Header.Field(
                    name: .init($0.name),
                    value: .init(unchecked: $0.value)
                )
            }
        )
        var body: [UInt8] = []
        if let buffer = try await request.body.collect().get() {
            body = Array(buffer.readableBytesView)
        }
        self.init(
            method: HTTP.Method(rawValue: request.method.rawValue),
            path: path,
            query: query,
            headers: headers,
            body: body
        )
    }
}

extension Server.Response {
    fileprivate init(_ response: Vapor.Response, on request: Vapor.Request) async throws {
        let body: [UInt8]
        if let buffer = try await response.body.collect(on: request.eventLoop).get() {
            body = Array(buffer.readableBytesView)
        } else {
            body = []
        }
        self.init(
            status: HTTP.Status(Int(response.status.code)),
            headers: HTTP.Headers(
                response.headers.map {
                    HTTP.Header.Field(
                        name: .init($0.name),
                        value: .init(unchecked: $0.value)
                    )
                }
            ),
            body: body
        )
    }
}
