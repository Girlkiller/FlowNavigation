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
    public func perform(_ action: FlowNavigationTypes.NavigationAction) {
        router.perform(action)
    }
    
    public func selectTab(_ tab: String) {
        router.selectTab(tab)
    }
    
    public func push(_ id: FlowNavigationTypes.RouteID, scope: NavigationScope = .automatic) {
        router.perform(.push(id, scope))
    }

    public func present(_ id: FlowNavigationTypes.RouteID, style: PresentStyle = .fullScreen(transparent: false), initialStack: [RouteID]? = nil) {
        router.perform(.present(id, style, initialStack: initialStack))
    }

    public func pop(scope: NavigationScope = .automatic) {
        router.perform(.pop(scope))
    }
    
    public func popToRoot(scope: NavigationScope = .automatic) {
        router.perform(.popToRoot(scope))
    }
    
    public func dismiss(_ id: FlowNavigationTypes.RouteID) {
        router.perform(.dismiss(id))
    }
    
    public func pushInPresent(_ presentID: FlowNavigationTypes.RouteID, route: FlowNavigationTypes.RouteID) {
        router.perform(.push(route, .specificPresent(presentID)))
    }
    
    public func popInPresent(_ presentID: FlowNavigationTypes.RouteID) {
        router.perform(.pop(.specificPresent(presentID)))
    }
    
    public func currentStack(for presentID: FlowNavigationTypes.RouteID) -> [FlowNavigationTypes.RouteID] {
        router.currentStack(for: presentID)
    }
    
    public func navigate(to url: URL, style: FlowNavigationTypes.NavigationStyle = .push, scope: NavigationScope = .automatic) async {
        await router.navigate(to: url, style: style, scope: scope)
    }
}
