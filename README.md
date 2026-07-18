# swift-server-vapor

Vapor adapters for the engine-free `Server` contracts.

The `Server Vapor` product is intentionally a thin integration boundary. It translates
`Server.Error`, request/application dependency scopes, canonical `Server.Response` values, and
generic Vapor middleware closures. HTTP policy vocabularies are provided by their owning packages
(`HTTP Redirect`, `HTTP Host`, `HTTP Cookies`, `HTTP Session`, `Metrics`, `Throttling`, and
`Favicon`) and are adapted here only where Vapor needs an engine-facing shape.

```swift
import Server_Vapor

let app = Application()
app.middleware.use { request, next in
    try await next.respond(to: request)
}
```

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-foundations/swift-server-vapor.git", from: "0.1.0")
]
```

Add `.product(name: "Server Vapor", package: "swift-server-vapor")` to a target's dependencies.

Licensed under the Apache License 2.0.
