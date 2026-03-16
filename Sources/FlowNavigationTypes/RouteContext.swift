//
//  File.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/16.
//

import Foundation

public struct RouteContext {

    private var dependencies: [ObjectIdentifier: Any] = [:]

    public init() {}

    public mutating func register<T>(_ value: T) {
        dependencies[ObjectIdentifier(T.self)] = value
    }

    public func resolve<T>(_ type: T.Type) -> T? {
        dependencies[ObjectIdentifier(T.self)] as? T
    }
}
