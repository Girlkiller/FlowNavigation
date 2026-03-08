//
//  RouteDescriptor.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/3.
//

import Foundation

public struct RouteDescriptor: Sendable {
    public let id: RouteID
    public let factory: @Sendable () -> Any
    public init(id: RouteID, factory: @escaping @Sendable () -> Any) {
        self.id = id
        self.factory = factory
    }
}
