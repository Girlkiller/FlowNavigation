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
import FlowNavigationTypes
import FlowNavigationDeepLink

// MARK: - RouteID 扩展
extension RouteID {
    static let home = RouteID("home")
    static let profile = RouteID("profile")
    static let settings = RouteID("settings")
    static let remind = RouteID("remind")
    static let me = RouteID("me")
    static let createPost = RouteID("createPost")
    static let testDetail = RouteID("testDetail")
}

struct AppConfig {
    let baseURL: String
}

// MARK: - Host App
@main
struct FlowNavigationApp: App {

    @StateObject private var registry: RouteRegistry
    @StateObject private var coordinator: FlowCoordinator

    private var tabs: [TabDescriptor] = []

    init() {

        // 1️⃣ 配置 DeepLink routeMap
        DeepLinkManager.shared.configure(routeMap: [
            "/home": .home,
            "/profile": .profile,
            "/settings": .settings,
            "/detail": .testDetail
        ])

        // 2️⃣ 获取全局 registry
        let localRegistry = RouteRegistry()

        localRegistry.context.register(AppConfig(baseURL: "https://www.baidu.com"))
        // 3️⃣ 注册模块
        localRegistry.registerModule(MyAppModule.self)
        localRegistry.registerModule(TestModule.self)

        // 4️⃣ 创建 TabNavigationState 初始状态（暂时空数组）
        let initialState = TabNavigationState(selectedTab: "home", tabs: [])
        let coordinator = FlowCoordinator(registry: localRegistry, initialState: initialState)
        NavigationEnvironment.shared.setup(router: coordinator)

        // 5️⃣ 初始化 @StateObject
        _registry = StateObject(wrappedValue: localRegistry)
        _coordinator = StateObject(wrappedValue: coordinator)

        // 6️⃣ 创建 Tabs，安全引用 coordinator
        self.tabs = [
            TabDescriptor(
                id: "home",
                title: "Home",
                icon: .system("house"),
                badge: 2,
                rootRoute: .home
            ),
            TabDescriptor(
                id: "profile",
                title: "Profile",
                icon: .system("person"),
                rootRoute: .profile
            ),
            TabDescriptor(
                id: "create",
                title: "",
                icon: .asset("icon_tab_add"),
                style: .centerButton,
                action: { [weak coordinator] in
                    coordinator?.perform(.present(.createPost, .fullScreen(transparent: true)))
                }
            ),
            TabDescriptor(
                id: "remind",
                title: "Remind",
                icon: .system("calendar"),
                rootRoute: .profile
            ),
            TabDescriptor(
                id: "me",
                title: "Me",
                icon: .system("person"),
                rootRoute: .profile
            )
        ]

        coordinator.state.tabs = tabs
    }

    var body: some Scene {
        WindowGroup {
            FlowNavigationContainer(
                coordinator: coordinator,
                registry: registry
            ) { tabID in
                // 根据 tabID 返回不同根视图
                switch tabID {
                case "home":
                    HomeRootView()
                case "profile":
                    ProfileView(userID: "123123")
                case "remind":
                    RemindView(id: "remind 123456")
                case "me":
                    MeView(userID: "abacsd")
                default:
                    Text("Unknown tab")
                }
            }
            .environmentObject(coordinator)
        }
    }
}
