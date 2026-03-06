//
//  NavigationEnvironment.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/3.
//

import Foundation
import FlowNavigationCoordinator
import FlowNavigationCore

@MainActor
public final class NavigationEnvironment {
    public static let shared = NavigationEnvironment()

    public let registry = RouteRegistry()
    public private(set) var coordinator: FlowCoordinator?

    private init() {}

    // Host App 在初始化时调用
    public func setupCoordinator(initialState: TabNavigationState) {
        guard coordinator == nil else { return }
        self.coordinator = FlowCoordinator(registry: registry, initialState: initialState)
    }
}
