//
//  File.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/15.
//

import Foundation

public protocol Router {
    func selectTab(_ tab: String)
    func push(_ id: RouteID)
    func pop() -> RouteID?
    func popToRoot()
    func present(_ id: RouteID, initialStack: [RouteID]?)
    func dismiss(_ id: RouteID)
    func pushInPresent(_ presentID: RouteID, route: RouteID)
    func popInPresent(_ presentID: RouteID) -> RouteID?
    func currentStack(for presentID: RouteID) -> [RouteID]
    func navigate(to url: URL, style: NavigationStyle) async
}

extension Router {
    public func present(_ id: RouteID, initialStack: [RouteID]? = nil) {
        present(id, initialStack: initialStack)
    }

    func navigate(to url: URL, style: NavigationStyle = .push) async {
        await navigate(to: url, style: style)
    }
}
