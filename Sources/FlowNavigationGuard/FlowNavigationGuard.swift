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

    private let redirect: NavigationRedirect
    private let isLoggedIn: @Sendable () async -> Bool

    public init(redirect: NavigationRedirect, isLoggedIn: @escaping @Sendable () async -> Bool) {
        self.redirect = redirect
        self.isLoggedIn = isLoggedIn
    }

    public func evaluate(to routeID: RouteID) async -> GuardResult {
        if routeID == loginRouteID() {
            return .allow
        }
        let loggedIn = await isLoggedIn()

        if loggedIn {
            return .allow
        } else {
            return .redirect(redirect)
        }
    }

    public func loginRouteID() -> RouteID {
        redirect.routeID
    }
}
