//
//  File.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/15.
//

import Foundation

public protocol Router {
    func selectTab(_ tab: String)
    func perform(_ action: NavigationAction)
    func currentStack(for presentID: RouteID) -> [RouteID]
    func navigate(to id: RouteID)
    func navigate(to url: URL, style: NavigationStyle, scope: NavigationScope) async
}

extension Router {
    public func navigate(to id: RouteID) {
        perform(.push(id, .automatic))
    }

    public func navigate(to url: URL, style: NavigationStyle = .push, scope: NavigationScope = .automatic) async {
        await navigate(to: url, style: style, scope: scope)
    }
}
