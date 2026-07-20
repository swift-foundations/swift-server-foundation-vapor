import Dependencies
import Favicon
import Foundation
import HTTP_Standard
import enum Server.Server
import Server_Vapor
import XCTest

final class FaviconResponseTests: XCTestCase {
    func testResponseReturnsConcreteServerResponseForAvailableIcon() async throws {
        let svg = Data("<svg></svg>".utf8)
        let favicon = Favicon(icons: .init(svg: svg))
        let expected = try XCTUnwrap(favicon.response(for: .icon(.svg)))

        let response = try await withDependencies {
            $0.favicon = favicon
        } operation: {
            try await Favicon.response(route: .icon(.svg))
        }

        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(
            response.headers.first("Content-Type")?.rawValue,
            expected.contentType
        )
        XCTAssertEqual(
            response.headers.first("Cache-Control")?.rawValue,
            expected.cacheControl
        )
        XCTAssertEqual(response.body, Array(expected.body))
        XCTAssertEqual(response.body, Array(svg))
    }

    func testResponseThrowsNotFoundForMissingIcon() async {
        let favicon = Favicon(icons: .init())

        do {
            _ = try await withDependencies {
                $0.favicon = favicon
            } operation: {
                try await Favicon.response(route: .favicon)
            }
            XCTFail("Expected Server.Error.notFound")
        } catch let error as Server.Error {
            guard case .notFound(let reason) = error else {
                XCTFail("Expected Server.Error.notFound, got \(error)")
                return
            }
            XCTAssertEqual(reason, "Not Found")
        } catch {
            XCTFail("Expected Server.Error, got \(error)")
        }
    }
}
