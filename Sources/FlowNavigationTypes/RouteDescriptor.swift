//
//  RouteDescriptor.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/3.
//

import Foundation

public struct RouteDescriptor: Sendable {

    public let id: RouteID
    public let hidesTabBar: Bool
    public let navBar: NavigationBarConfig
    public let guards: [RouteGuard]
    public let skipGuards: Bool
    public let factory: @MainActor @Sendable (RouteContext) -> Any

    public init(
        id: RouteID,
        hidesTabBar: Bool = true,
        navBar: NavigationBarConfig = NavigationBarConfig(),
        guards: [RouteGuard] = [],
        skipGuards: Bool = false,
        factory: @escaping @MainActor @Sendable (RouteContext) -> Any
    ) {
        self.id = id
        self.hidesTabBar = hidesTabBar
        self.navBar = navBar
        self.guards = guards
        self.skipGuards = skipGuards
        self.factory = factory
    }
}
