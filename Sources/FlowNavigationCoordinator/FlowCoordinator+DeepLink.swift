//
//  File.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/8.
//

import Foundation
import FlowNavigationDeepLink
import FlowNavigationGuard
import FlowNavigationCore
import FlowNavigationTypes

// MARK: - Coordinator Extension: DeepLink Navigation
@MainActor
extension FlowCoordinator {

    /// 支持一个或多个 DeepLinkParser
    public func navigate(to url: URL, style: NavigationStyle = .push, parsers: [DeepLinkParser] = []) async {
        var parsers = parsers
        let defaultParser = DeepLinkManager.shared.default

        if !parsers.contains(where: {
            ObjectIdentifier($0) == ObjectIdentifier(defaultParser)
        }) {
            parsers.append(defaultParser)
        }

        for parser in parsers {
            if let result = parser.parse(url: url) {
                let routeID = result.route
                let params = result.params

                // 保存参数到 registry，让页面 factory 获取
                registry.setParameters(params, for: routeID)

                // 判断 routeDescriptor 是否有 guards
                if let descriptor = registry.descriptor(for: routeID) {
                    for guardObj in descriptor.guards {
                        if !(await guardObj.canNavigate(to: routeID)) {
                            if let auth = guardObj as? AuthGuard {
                                self.present(auth.loginRouteID())
                            }
                            return
                        }
                    }
                }
                // 直接打开页面
                switch style {
                case .push:
                    push(routeID)
                case .present(let presentStyle):
                    present(routeID, style: presentStyle)
                }
                return
            }
        }
    }
}

// MARK: - RouteRegistry 参数存储扩展
@MainActor
extension RouteRegistry {
    private static var parametersStore: [RouteID: RouteParameters] = [:]

    public func setParameters(_ params: RouteParameters, for route: RouteID) {
        Self.parametersStore[route] = params
    }

    public func parameters(for route: RouteID) -> RouteParameters {
        Self.parametersStore[route] ?? RouteParameters()
    }
}
