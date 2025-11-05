//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 19/12/2024.
//

import ServerFoundation
import Translating
import Vapor

extension Vapor.Request: @retroactive DependencyKey {
    public static let testValue: Vapor.Request? = nil
    public static let liveValue: Vapor.Request? = nil
}

extension DependencyValues {
    public var request: Vapor.Request? {
        get { self[Vapor.Request.self] }
        set { self[Vapor.Request.self] = newValue }
    }
}

public struct RequestError: Error {
    let int: Int

    public init(_ int: Int) {
        self.int = int
    }
}

extension Vapor.Request {
    public var isFormSubmission: Bool {
        guard let contentType = headers.contentType else {
            return false
        }
        return contentType == .urlEncodedForm || contentType == .formData
    }
}

extension Vapor.Request {
    /// Checks if the request is an AJAX request expecting JSON response
    public var isAJAXRequest: Bool {
        // Check for X-Requested-With header (most reliable AJAX indicator)
        if headers.first(name: "X-Requested-With")?.lowercased() == "xmlhttprequest" {
            return true
        }

        // Check if JSON is the primary (first) Accept type
        // This avoids false positives from browsers that include */* at the end
        if let firstAccept = headers.accept.first,
            firstAccept.mediaType == .json
        {
            return true
        }

        return false
    }

    /// Checks if this is a traditional form submission (not AJAX)
    public var isTraditionalFormSubmission: Bool {
        return isFormSubmission && !isAJAXRequest
    }
}

extension Request {
    /// Attempts to extract geolocation information from request headers
    public var geoLocation: GeoLocation? {
        // Cloudflare headers
        let country = headers.first(name: .cfIpCountry)
        let region = headers.first(name: .cfRegion)
        let city = headers.first(name: .cfCity)

        // If any geolocation data is present, return it
        if country != nil || region != nil || city != nil {
            return GeoLocation(
                country: country,
                region: region,
                city: city
            )
        }

        return nil
    }
}

extension Request {
    /// Gets the real IP address considering various headers
    public var realIP: String {
        // Try Cloudflare header first
        if let cfConnectingIP = headers.first(name: .cfConnectingIp) {
            return cfConnectingIP
        }

        // Then try X-Real-IP
        if let xRealIP = headers.first(name: .xRealIp) {
            return xRealIP
        }

        // Then try X-Forwarded-For (first IP in the list)
        if let forwardedFor = headers.first(name: .xForwardedFor)?.split(separator: ",").first {
            return String(forwardedFor).trimmingCharacters(in: .whitespaces)
        }

        // Fall back to the direct remote address
        return remoteAddress?.hostname ?? "unknown"
    }
}

extension Request {
    public struct GeoLocation: Sendable, Hashable {
        public let country: String?
        public let region: String?
        public let city: String?
    }
}
