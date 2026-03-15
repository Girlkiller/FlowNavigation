//
//  FlowNavigationDeepLink.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/3.
//

import FlowNavigationCore
import Foundation
import FlowNavigationTypes

public class DeepLinkParser {

    /// path -> RouteID 映射
    private let routeMap: [String: RouteID]

    public init(routeMap: [String: RouteID]) {
        self.routeMap = routeMap
    }

    /// 解析 URL -> (RouteID, RouteParameters)
    public func parse(url: URL) -> (route: RouteID, params: RouteParameters)? {
        let pathSegment = url.pathComponents.dropFirst().first ?? url.path // path 第一个 segment
        let route: RouteID
        if let mapped = routeMap[url.path] ?? routeMap["/\(pathSegment)"] {
            route = mapped
        } else {
            route = RouteID(pathSegment)
        }

        // 解析 query 参数
        var paramsDict: [String: Any] = [:]
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            for item in queryItems {
                paramsDict[item.name] = item.value
            }
        }

        // 尝试解析 body 或 JSON 参数
        if let jsonData = url.fragment?.data(using: .utf8) {
            if let jsonObj = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                for (k,v) in jsonObj { paramsDict[k] = v }
            }
        }

        let params = RouteParameters(values: paramsDict)
        return (route, params)
    }

    /// 支持通过自定义规则注册更多路由
    public func register(path: String, route: RouteID) -> DeepLinkParser {
        var newMap = routeMap
        newMap[path] = route
        return DeepLinkParser(routeMap: newMap)
    }
}
