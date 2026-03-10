//
//  FlowNavigationUIKit.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/3.
//

import UIKit
import FlowNavigationCore
import FlowNavigationCoordinator
import FlowNavigationTypes

public final class FlowUIKitBridge {

    private let registry: RouteRegistry

    public init(registry: RouteRegistry) { self.registry = registry }

    public func viewController(for id: RouteID) async -> UIViewController? {
        guard let descriptor = await registry.descriptor(for: id),
              let vc = await descriptor.factory() as? UIViewController
        else { return nil }
        return vc
    }

    public func presentStack(on host: UIViewController, presentID: RouteID, coordinator: FlowCoordinator) async {
        let nav = await UINavigationController()
        let stack = await coordinator.currentStack(for: presentID)
        for route in stack {
            if let vc = await viewController(for: route) { await nav.pushViewController(vc, animated: false) }
        }
        await host.present(nav, animated: true)
    }
}
