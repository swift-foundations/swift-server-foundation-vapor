//
//  Vapor.Request.Scope.swift
//  swift-server-foundation-vapor
//
//  The `\.vapor` dependency container: the engine-side counterpart to swift-server's
//  `\.server` container.
//

import Dependencies
import Vapor

extension Vapor.Request {
    /// The ambient values for the in-flight request scope, reached through ``Dependency/Values/vapor``.
    ///
    /// ## Why a container, and not a flat key
    ///
    /// Two membranes vend an ambient request under the *same* name `\.request`: this one (the engine
    /// type, `Vapor.Request`) and swift-server's `Server.Dependencies` integration (the engine-free
    /// membrane type, `Server.Request`). A module importing both would face two distinct
    /// `Dependency.Values.request` properties of **different types**.
    ///
    /// That collision has not detonated only because no single module imports both declarers today —
    /// this package does not depend on swift-server at all. It detonates the moment one does.
    ///
    /// Naming the container makes the call site say which request it means, and makes the collision
    /// impossible rather than merely absent:
    ///
    /// ```swift
    /// @Dependency(\.vapor.request) var request   // the engine type
    /// @Dependency(\.server.request) var request  // the membrane type
    /// ```
    ///
    /// The flat ``Dependency/Values/request`` still exists and still works; it is retired only once
    /// every call site in the ecosystem has moved, so nothing breaks on the mint.
    ///
    /// - Note: The type nests under `Vapor.Request` so the engine-side request scope remains
    ///   unambiguous when this adapter is imported alongside the engine-free `Server` package.
    public struct Scope: Sendable {
        /// The ambient `Vapor.Request`, or `nil` outside a request scope.
        public var request: Vapor.Request?

        public init(request: Vapor.Request? = nil) {
            self.request = request
        }
    }
}

/// The dependency key backing ``Dependency/Values/vapor``. Live and test both default to an empty
/// scope — there is no ambient request outside a request scope, and a fabricated stand-in would let
/// a graph read a request that never arrived.
private enum VaporKey: Dependency.Key {}

extension VaporKey {
    static let liveValue = Vapor.Request.Scope()
    static let testValue = Vapor.Request.Scope()
}

extension Dependency.Values {
    /// The ambient ``Vapor/Request/Scope`` — the Vapor engine's values for the in-flight request.
    ///
    /// ```swift
    /// @Dependency(\.vapor.request) var request
    /// ```
    public var vapor: Vapor.Request.Scope {
        get { self[VaporKey.self] }
        set { self[VaporKey.self] = newValue }
    }
}
