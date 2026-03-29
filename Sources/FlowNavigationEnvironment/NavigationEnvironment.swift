//
//  NavigationEnvironment.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/3.
//

import Foundation
import FlowNavigationTypes
import FlowNavigationCoordinator
import FlowNavigationCore
import FlowNavigationGuard

import Foundation

@MainActor
public final class NavigationEnvironment {

    public static let shared = NavigationEnvironment()

    private init() {}

    private var _router: Router?

    /// 当前 Router
    public var router: Router {
        guard let router = _router else {
            fatalError(
                """
                NavigationEnvironment.router not configured.
                Call NavigationEnvironment.shared.setup(router:) in App startup.
                """
            )
        }
        return router
    }

    /// 注入 Router（App 启动时调用）
    public func setup(router: Router) {

        precondition(
            _router == nil,
            "NavigationEnvironment.router already configured."
        )

        self._router = router
    }

}

extension NavigationEnvironment: Router {
    public func selectTab(_ tab: String) {
        router.selectTab(tab)
    }
    
    public func push(_ id: FlowNavigationTypes.RouteID, scope: NavigationScope) {
        router.push(id, scope: scope)
    }
    
    public func pop(scope: NavigationScope = .automatic) -> FlowNavigationTypes.RouteID? {
        router.pop(scope: scope)
    }
    
    public func popToRoot(scope: NavigationScope = .automatic) {
        router.popToRoot(scope: scope)
    }
    
    public func dismiss(_ id: FlowNavigationTypes.RouteID) {
        router.dismiss(id)
    }
    
    public func pushInPresent(_ presentID: FlowNavigationTypes.RouteID, route: FlowNavigationTypes.RouteID) {
        router.pushInPresent(presentID, route: route)
    }
    
    public func popInPresent(_ presentID: FlowNavigationTypes.RouteID) -> FlowNavigationTypes.RouteID? {
        router.popInPresent(presentID)
    }
    
    public func currentStack(for presentID: FlowNavigationTypes.RouteID) -> [FlowNavigationTypes.RouteID] {
        router.currentStack(for: presentID)
    }
    
    public func navigate(to url: URL, style: FlowNavigationTypes.NavigationStyle = .push, scope: NavigationScope = .automatic) async {
        await router.navigate(to: url, style: style, scope: scope)
    }
}
