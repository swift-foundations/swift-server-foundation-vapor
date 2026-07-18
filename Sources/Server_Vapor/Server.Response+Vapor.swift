import Foundation
import Server
import Vapor

extension Vapor.Response {
    /// Converts the engine-free response at the Vapor boundary.
    public init(_ response: Server.Response) {
        let headers = Dictionary(
            response.headers.map { ($0.name.rawValue, $0.value.rawValue) },
            uniquingKeysWith: { first, _ in first }
        )
        self.init(
            status: .init(statusCode: response.status.code),
            headers: headers,
            body: .init(data: Data(response.body))
        )
    }
}
