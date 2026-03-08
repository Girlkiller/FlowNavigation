//
//  File.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/8.
//

import Foundation
import FlowNavigationCore
import SwiftUI
import FlowNavigationTypes

// MARK: - 全局管理 DeepLink
@MainActor
public final class DeepLinkManager {
    public static let shared = DeepLinkManager()

    /// 全局路由映射
    private(set) var routeMap: [String: RouteID] = [:]

    /// 默认 DeepLinkParser
    public lazy var `default`: DeepLinkParser = DeepLinkParser(routeMap: routeMap)

    private init() {}

    /// 注入全局 routeMap
    public func configure(routeMap: [String: RouteID]) {
        self.routeMap = routeMap
        self.default = DeepLinkParser(routeMap: routeMap)
    }
}
