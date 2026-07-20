import Dependencies
import Favicon
import HTTP_Standard
public import Server

extension Favicon {
    /// Renders the favicon response as a concrete, engine-free `Server.Response`.
    public static func response(
        route: Favicon.Route
    ) async throws -> Server.Response {
        @Dependency(\.favicon) var favicon
        guard let response = favicon.response(for: route) else {
            throw Server.Error.notFound("Not Found")
        }

        let headers = try HTTP.Headers([
            .init(name: "Content-Type", value: response.contentType),
            .init(name: "Cache-Control", value: response.cacheControl),
        ])
        return Server.Response(
            headers: headers,
            body: Array(response.body)
        )
    }
}
