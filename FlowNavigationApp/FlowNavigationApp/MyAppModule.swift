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
            RouteDescriptor(id: .home) { _ in
                AnyView(HomeRootView())
            }
        )
        registry.register(RouteDescriptor(id: .createPost) { context in
            AnyView(
                ZStack {
                    Color.black
                        .opacity(0.4)
                        .ignoresSafeArea()

                    Text("Create Post Page: " + "\(String(describing: registry.context.resolve(AppConfig.self)))")
                        .font(.title)
                        .foregroundColor(.white)
                }
            )
        })

        registry.register(
            RouteDescriptor(id: .profile) { context in

                let params = registry.parameters(for: .profile)
                let userID = params.get("id") ?? "unknown"

                return AnyView(
                    ProfileView(userID: userID)
                )
            }
        )
    }
}
