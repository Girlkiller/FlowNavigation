//
//  FlowNavigationAppApp.swift
//  FlowNavigationApp
//
//  Created by feng qiu on 2026/3/3.
//

import SwiftUI
import FlowNavigationCore
import FlowNavigationGuard
import FlowNavigationUI
import FlowNavigationDeepLink
import FlowNavigationUIKit
import FlowNavigationCoordinator

@main
struct DemoApp: App {

    @StateObject var registry = RouteRegistry()
    @StateObject var coordinator: FlowCoordinator

    init() {
        let r = RouteRegistry()
        r.register(RouteDescriptor(id: .home) { AnyView(Text("Home Page")) })
        r.register(RouteDescriptor(id: .profile) { AnyView(Text("Profile Page")) })
        let c = FlowCoordinator(registry: r, guards: [LoginGuard { true }])
        _registry = StateObject(wrappedValue: r)
        _coordinator = StateObject(wrappedValue: c)
    }

    var body: some Scene {
        WindowGroup {
            FlowNavigationContainer(coordinator: coordinator, registry: registry) {
                Text("Root Page")
            }
        }
    }
}
