//
//  MyAppModule.swift
//  FlowNavigationApp
//
//  Created by feng qiu on 2026/3/10.
//

import SwiftUI
import Foundation
import FlowNavigationCore
import FlowNavigationTypes

struct MyAppModule: @preconcurrency RouteModule {

    static let moduleID = "MyAppModule"

    @MainActor
    static func register(into registry: RouteRegistry) {

        registry.register(
            RouteDescriptor(id: .home) {
                AnyView(HomeRootView())
            }
        )
        registry.register(RouteDescriptor(id: .createPost) {
            AnyView(Text("Create Post Page"))
        })

        registry.register(
            RouteDescriptor(id: .profile) {

                let params = registry.parameters(for: .profile)
                let userID = params["id"] ?? "unknown"

                return AnyView(
                    ProfileView(userID: userID)
                )
            }
        )
    }
}
