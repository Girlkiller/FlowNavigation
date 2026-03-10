//
//  RouteDescriptor.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/3.
//

import Foundation

public struct RouteDescriptor: Sendable {
    public let id: RouteID
    public let factory: @MainActor @Sendable () -> Any
    public let guards: [RouteGuard]

    public init(id: RouteID,
                guards: [RouteGuard] = [],
                factory: @escaping @MainActor @Sendable () -> Any) {
        self.id = id
        self.guards = guards
        self.factory = factory
    }
}
