import Server
public import protocol Vapor.AsyncResponseEncodable
public import class Vapor.Request
public import class Vapor.Response

// swift-format-ignore: AvoidRetroactiveConformances
extension Server.Response: @retroactive AsyncResponseEncodable {
    public func encodeResponse(for request: Vapor.Request) async throws -> Vapor.Response {
        Vapor.Response(self)
    }
}
