import Foundation
import HTTP_Standard
public import Server
import class Vapor.Request

extension Server.Request {
    /// Collects a Vapor transport request into the engine-free server request value.
    public init(_ request: Server.Vapor.Request) async throws(Server.Error) {
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
        let body: [UInt8]
        do {
            if let buffer = try await request.body.collect().get() {
                body = Array(buffer.readableBytesView)
            } else {
                body = []
            }
        } catch {
            throw .engine(String(describing: error))
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
