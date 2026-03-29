//
//  File.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/15.
//

import Foundation

public protocol Router {
    func selectTab(_ tab: String)
    func push(_ id: RouteID, scope: NavigationScope)
    func pop(scope: NavigationScope) -> RouteID?
    func popToRoot(scope: NavigationScope)
    func present(_ id: RouteID, initialStack: [RouteID]?)
    func dismiss(_ id: RouteID)
    func pushInPresent(_ presentID: RouteID, route: RouteID)
    func popInPresent(_ presentID: RouteID) -> RouteID?
    func currentStack(for presentID: RouteID) -> [RouteID]
    func navigate(to url: URL, style: NavigationStyle, scope: NavigationScope) async
}

extension Router {
    public func present(_ id: RouteID, initialStack: [RouteID]? = nil) {
        present(id, initialStack: initialStack)
    }

    public func navigate(to url: URL, style: NavigationStyle = .push, scope: NavigationScope = .automatic) async {
        await navigate(to: url, style: style, scope: scope)
    }
}
