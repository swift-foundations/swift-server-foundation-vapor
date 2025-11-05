//
//  File.swift
//  coenttb-server-vapor
//
//  Created by Coen ten Thije Boonkkamp on 03/03/2025.
//

import Foundation
import ServerFoundationVapor
import URLRouting

#if compiler(>=6.0) && canImport(Testing)
    import VaporTesting

    extension TestingHTTPRequest {
        public init(_ urlRequestData: URLRequestData) throws {
            // Create HTTP method from URLRequestData method
            guard let methodString = urlRequestData.method else {
                throw URLError(.badURL, userInfo: ["reason": "Missing HTTP method"])
            }
            let method = HTTPMethod(rawValue: methodString)

            // Construct URI from URLRequestData components
            var url = URI()

            // Set scheme
            if let scheme = urlRequestData.scheme {
                url.scheme = scheme
            }

            // Set host
            if let host = urlRequestData.host {
                url.host = host
            }

            // Set port
            if let port = urlRequestData.port {
                url.port = port
            }

            // Set path
            url.path = "/" + urlRequestData.path.joined(separator: "/")

            // Set query parameters
            if !urlRequestData.query.fields.isEmpty {
                var queryItems: [String: String] = [:]
                for (name, values) in urlRequestData.query.fields {
                    // Use first value for simplicity
                    if let firstValue = values.first, let unwrappedValue = firstValue {
                        queryItems[name] = String(unwrappedValue)
                    }
                }
                url.query = queryItems.map { "\($0)=\($1)" }.joined(separator: "&")
            }

            // Set fragment
            if let fragment = urlRequestData.fragment {
                url.fragment = fragment
            }

            // Create headers
            var headers = HTTPHeaders()
            for (name, values) in urlRequestData.headers.fields {
                for value in values {
                    if let value {
                        headers.add(name: name, value: String(value))
                    }
                }
            }

            var body: ByteBuffer {
                urlRequestData.body.flatMap { data in ByteBuffer(data: data) }
                    ?? {
                        let allocator = ByteBufferAllocator()
                        return allocator.buffer(capacity: 0)
                    }()
            }

            self.init(method: method, url: url, headers: headers, body: body)
        }
    }
#endif
