import Dependencies
import Vapor

extension Dependency.Values {
    public var application: Vapor.Application {
        get { self[Vapor.Application.Key.self] }
        set { self[Vapor.Application.Key.self] = newValue }
    }
}

extension Vapor.Application {
    fileprivate enum Key: Dependency.Key.Test {
        static var testValue: Vapor.Application { .init(.testing) }
    }
}
