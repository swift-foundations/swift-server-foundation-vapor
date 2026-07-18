import Server
import protocol Vapor.AsyncResponseEncodable
import class Vapor.Request
import class Vapor.Response

// swift-format-ignore: AvoidRetroactiveConformances
extension Server.Response: @retroactive AsyncResponseEncodable {
    public func encodeResponse(for request: Vapor.Request) async throws -> Vapor.Response {
        Vapor.Response(self)
    }
}
