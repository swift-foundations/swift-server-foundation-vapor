//
//  ReadmeVerificationTests.swift
//  swift-server-foundation-vapor
//
//  Created on 30/10/2025.
//

import ServerFoundationVapor
import Testing
import Throttling

#if compiler(>=6.0) && canImport(Testing)

    @Suite
    struct Test {

        @Test
        func `Example from README: Closure-Based Middleware - compiles`() throws {
            // This test verifies that the README example compiles
            // The actual usage would be in a running app context

            // Example from README lines 56-67 (structure verification)
            let _: (Application) -> Void = { app in
                app.middleware.use { request, next in
                    print("Request received: \(request.url)")
                    let response = try await next.respond(to: request)
                    print("Response status: \(response.status)")
                    return response
                }
            }

            // Test passes if it compiles
            #expect(true)
        }

        @Test
        func `Example from README: Rate Limiting Middleware - compiles`() async throws {
            // Example from README lines 71-88
            let rateLimiter = RateLimiter<String>(
                windows: [.minutes(1, maxAttempts: 100)]
            )

            let _: RateLimiter<String>.Middleware = RateLimiter.Middleware(
                rateLimiter: rateLimiter,
                getKey: { request in
                    request.headers.first(name: .xRealIp) ?? "unknown"
                },
                onRejected: nil
            )

            // Test passes if it compiles
            #expect(true)
        }

        @Test
        func `Example from README: Custom HTTP Headers`() throws {
            // Example from README lines 93-111 (structure verification)
            let _: (Request) async throws -> Response = { request in
                let response = Response(status: .ok)

                // Add rate limit headers
                response.headers.add(name: .xRateLimitLimit, value: "100")
                response.headers.add(name: .xRateLimitRemaining, value: "95")

                // Add security headers
                response.headers.add(
                    name: .strictTransportSecurity,
                    value: "max-age=31536000; includeSubDomains"
                )

                return response
            }

            // Test passes if it compiles
            #expect(true)
        }

        @Test
        func `HTTP Header Extensions`() {
            // Verify custom header names exist (Vapor normalizes to lowercase)
            #expect(HTTPHeaders.Name.xRateLimitLimit.description == "x-ratelimit-limit")
            #expect(HTTPHeaders.Name.xRateLimitRemaining.description == "x-ratelimit-remaining")
            #expect(HTTPHeaders.Name.xRateLimitReset.description == "x-ratelimit-reset")
            #expect(
                HTTPHeaders.Name.xEmailRateLimitRemaining.description
                    == "x-email-ratelimit-remaining"
            )
            #expect(
                HTTPHeaders.Name.xIPRateLimitRemaining.description == "x-ip-ratelimit-remaining"
            )
            #expect(HTTPHeaders.Name.xRateLimitSource.description == "x-ratelimit-source")
            #expect(HTTPHeaders.Name.xForwardedProto.description == "x-forwarded-proto")
            #expect(
                HTTPHeaders.Name.strictTransportSecurity.description == "strict-transport-security"
            )
            #expect(HTTPHeaders.Name.reauthorization.description == "reauthorization")
            #expect(HTTPHeaders.Name.xRealIp.description == "x-real-ip")
            #expect(HTTPHeaders.Name.cfConnectingIp.description == "cf-connecting-ip")
            #expect(HTTPHeaders.Name.cfIpCountry.description == "cf-ipcountry")
            #expect(HTTPHeaders.Name.cfRegion.description == "cf-region")
            #expect(HTTPHeaders.Name.cfCity.description == "cf-city")
        }

        @Test
        func `Middleware Closure Type Exists`() {
            // Verify that the Closure middleware type exists
            let _: Vapor.Middlewares.Closure.Type = Vapor.Middlewares.Closure.self
            #expect(true)
        }

        @Test
        func `Rate Limiting Middleware Type Exists`() {
            // Verify that the rate limiting middleware type exists
            let _: Vapor.Middlewares.Ratelimiting<String>.Type = Vapor.Middlewares.Ratelimiting<
                String
            >
            .self
            #expect(true)
        }
    }
#endif
