import Logging
import Metrics
import Vapor

extension HTTPHeaders.Name {
    fileprivate static let requestID = HTTPHeaders.Name("request-id")
}

extension Vapor.Middlewares {
    public struct RequestTiming: AsyncMiddleware {
        private let skipStaticFileDetection: Bool

        public init(skipStaticFileDetection: Bool = false) {
            self.skipStaticFileDetection = skipStaticFileDetection
        }

        public func respond(to request: Vapor.Request, chainingTo next: Vapor.AsyncResponder)
            async throws -> Vapor.Response
        {
            let clock = ContinuousClock()
            let start = clock.now
            let response = try await next.respond(to: request)
            let elapsed = start.duration(to: clock.now)
            let isStaticFile =
                skipStaticFileDetection
                ? false : isLikelyStaticFile(request: request, response: response)
            let timer = Metrics.Timer(
                label: "http.server.request.duration",
                dimensions: [
                    ("method", request.method.rawValue),
                    ("status_code", String(response.status.code)),
                ],
                preferredDisplayUnit: .milliseconds
            )
            timer.recordNanoseconds(Self.nanoseconds(in: elapsed))

            var metadata: Logger.Metadata = [
                "elapsed_ms": .stringConvertible(elapsed / .milliseconds(1))
            ]
            if let requestID = request.headers.first(name: .requestID) {
                metadata["request_id"] = .string(requestID)
            }
            if isStaticFile {
                metadata["static_file"] = .stringConvertible(true)
            }
            request.logger.log(
                level: logLevel(for: response.status, isStaticFile: isStaticFile),
                "\(response.status.code) \(request.method.rawValue) \(request.url.path)",
                metadata: metadata
            )
            return response
        }

        private static func nanoseconds(in duration: Duration) -> Int64 {
            let components = duration.components
            return components.seconds * 1_000_000_000 + components.attoseconds / 1_000_000_000
        }

        private func isLikelyStaticFile(
            request: Vapor.Request,
            response: Vapor.Response
        ) -> Bool {
            guard request.method == .GET || request.method == .HEAD else { return false }
            guard response.status == .ok || response.status == .notModified else { return false }

            if let contentType = response.headers.contentType {
                let staticTypes = [
                    "image/", "text/css", "application/javascript",
                    "font/", "video/", "audio/",
                ]
                return staticTypes.contains { contentType.serialize().starts(with: $0) }
            }

            let staticExtensions = [
                ".css", ".js", ".jpg", ".jpeg", ".png", ".gif",
                ".svg", ".ico", ".woff", ".woff2", ".ttf",
            ]
            return staticExtensions.contains { request.url.path.hasSuffix($0) }
        }

        private func logLevel(for status: HTTPStatus, isStaticFile: Bool) -> Logger.Level {
            if isStaticFile {
                return .trace
            }

            switch status.code {
            case 500...: return .error
            case 400..<500: return .warning
            case 304: return .trace
            default: return .info
            }
        }
    }
}
