//
//  File.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 04-01-2024.
//

import Dependencies
import Foundation
import Vapor

extension DependencyValues {
    public var application: Vapor.Application {
        get { self[VaporApplicationKey.self] }
        set { self[VaporApplicationKey.self] = newValue }
    }
}

public enum VaporApplicationKey: TestDependencyKey {
    public static var testValue: Vapor.Application { Application(.testing) }
}
