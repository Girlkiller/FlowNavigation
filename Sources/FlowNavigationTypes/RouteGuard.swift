//
//  File.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/8.
//

import Foundation

public protocol RouteGuard: Sendable {
    func evaluate(to routeID: RouteID) async -> GuardResult
}

extension RouteGuard {
    func evaluate(to routeID: RouteID) async -> GuardResult {
        return .allow
    }
}
