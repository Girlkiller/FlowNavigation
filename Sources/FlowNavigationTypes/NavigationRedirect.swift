//
//  File.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/22.
//

import Foundation

public struct NavigationRedirect {
    public let routeID: RouteID
    public let style: NavigationStyle

    public init(routeID: RouteID, style: NavigationStyle) {
        self.routeID = routeID
        self.style = style
    }
}
