//
//  FlowNavigationDeepLink.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/3.
//

import FlowNavigationCore
import Foundation
import FlowNavigationTypes

/// 路由参数封装
public struct RouteParameters {
    public let values: [String: String]

    public init(values: [String: String] = [:]) {
        self.values = values
    }

    public subscript(key: String) -> String? {
        return values[key]
    }
}

/// 支持 DeepLink 解析并提取参数
public struct DeepLinkParser {

    /// 简单路由映射：path -> RouteID
    private let routeMap: [String: RouteID]

    public init(routeMap: [String: RouteID]) {
        self.routeMap = routeMap
    }

    /// 解析 URL -> RouteID + 参数
    /// - Returns: (RouteID, RouteParameters) 元组
    public func parse(url: URL) -> (route: RouteID, params: RouteParameters)? {
        // 1️⃣ 查找路由映射
        guard let route = routeMap[url.path] else { return nil }

        // 2️⃣ 解析 query 参数
        var paramsDict: [String: String] = [:]
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            for item in queryItems {
                paramsDict[item.name] = item.value
            }
        }

        let params = RouteParameters(values: paramsDict)
        return (route, params)
    }
}
