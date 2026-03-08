//
//  File.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/8.
//

import Foundation

public protocol RouteGuard: Sendable {
    func canNavigate(to route: RouteID) async -> Bool
}
