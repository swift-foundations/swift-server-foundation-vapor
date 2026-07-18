import Dependencies
import Favicon
import Vapor

extension Favicon {
    public static func response(
        route: Favicon.Route
    ) async throws -> any AsyncResponseEncodable {
        @Dependency(\.favicon) var favicon
        guard let response = favicon.response(for: route) else {
            throw Abort(.notFound)
        }

        return Vapor.Response(
            status: .ok,
            headers: [
                "Content-Type": response.contentType,
                "Cache-Control": response.cacheControl,
            ],
            body: .init(data: response.body)
        )
    }
}
