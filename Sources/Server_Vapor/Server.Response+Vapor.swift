import Foundation
import Server
import class Vapor.Response

extension Vapor.Response {
    /// Converts the engine-free response at the Vapor boundary.
    public convenience init(_ response: Server.Response) {
        self.init(
            status: .init(statusCode: response.status.code),
            headers: .init(response.headers.map { ($0.name.rawValue, $0.value.rawValue) }),
            body: .init(data: Data(response.body))
        )
    }
}
