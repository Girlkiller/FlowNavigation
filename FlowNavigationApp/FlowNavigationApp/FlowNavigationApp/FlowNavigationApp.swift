//
//  FlowNavigationApp.swift
//  FlowNavigationApp
//
//  Created by feng qiu on 2026/3/3.
//

import SwiftUI
import FlowNavigationCore
import FlowNavigationCoordinator
import FlowNavigationUI
import FlowNavigationEnvironment

extension RouteID {
    static let home = RouteID("home")
    static let profile = RouteID("profile")
    static let settings = RouteID("settings")
}

// Host App
@main
struct FlowNavigationApp: App {
    @StateObject private var registry: RouteRegistry
    @StateObject private var coordinator: FlowCoordinator

    init() {
        // 先创建本地 registry 实例
        let localRegistry = NavigationEnvironment.shared.registry

        // 注册 Host App 页面
        localRegistry.registerModule(MyAppModule.self)

        // 创建初始导航状态，由业务决定
        let initialState = TabNavigationState(
            selectedTab: "home",
            tabs: ["home", "profile", "settings"]
        )
        NavigationEnvironment.shared.setupCoordinator(initialState: initialState)

        // 初始化 @StateObject
        _registry = StateObject(wrappedValue: localRegistry)
        _coordinator = StateObject(wrappedValue: NavigationEnvironment.shared.coordinator!)
    }

    var body: some Scene {
        WindowGroup {
            FlowNavigationContainer(coordinator: coordinator,
                                    registry: registry) {
                HomeRootView()
            }
            .environmentObject(coordinator)
        }
    }
}

// Host app 自己的页面
struct HomeRootView: View {
    @EnvironmentObject var coordinator: FlowCoordinator

    var body: some View {
        VStack(spacing: 20) {
            Button("Go to Profile") {
                coordinator.push(.profile)
            }
            Button("Open Settings Sheet") {
                coordinator.present(.settings)
            }
        }
    }
}

// Host app 模块
struct MyAppModule: RouteModule {
    static let moduleID = "MyAppModule"

    @MainActor static func register(into registry: RouteRegistry) {
        // 必须传 RouteDescriptor
        registry.register(RouteDescriptor(id: .home) {
            AnyView(Text("Home Page"))
        })
        registry.register(RouteDescriptor(id: .profile) {
            AnyView(Text("Profile Page"))
        })
        registry.register(RouteDescriptor(id: .settings) {
            AnyView(Text("Settings Page"))
        })
    }
}
