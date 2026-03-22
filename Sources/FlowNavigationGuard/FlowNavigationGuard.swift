//
//  FlowNavigationGuard.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/3.
//

import Foundation
import FlowNavigationCore
import FlowNavigationTypes

public final class AuthGuard: RouteGuard {

    private let isLoggedIn: @Sendable () async -> Bool
    private let loginRoute: RouteID

    public init(isLoggedIn: @escaping @Sendable () async -> Bool, loginRoute: RouteID) {
        self.isLoggedIn = isLoggedIn
        self.loginRoute = loginRoute
    }

    public func canNavigate(to route: RouteID) async -> Bool {
        if route == loginRouteID() {
            return true
        }
        return await isLoggedIn()
    }

    public func loginRouteID() -> RouteID {
        loginRoute
    }
}
