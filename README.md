# FlowNavigation

FlowNavigation 是一个 **模块化 iOS 导航框架**，用于解决大型 App 中复杂的导航问题，例如：

- 多 Tab NavigationStack
- 跨模块页面跳转
- Sheet / FullScreen Navigation
- DeepLink 路由
- 登录拦截（Route Guard）
- SwiftUI 与 UIKit 混合导航
- 多 SDK 共享导航系统

适用于：

- 大型 iOS App
- 模块化架构
- SDK 化开发
- SwiftUI 项目

---

# Features

- 🧭 **统一路由系统**
- 🧩 **模块化页面注册**
- 🔐 **Route Guard（权限拦截）**
- 🔗 **DeepLink 支持**
- 🧱 **UIKit 页面支持**
- 📦 **Swift Package Manager**
- 🧑‍💻 **多 SDK 共享导航**

---

# Architecture

FlowNavigation
│
├── FlowNavigationCore
│ ├── RouteID
│ ├── RouteRegistry
│ ├── RouteDescriptor
│ └── TabNavigationState
│
├── FlowNavigationCoordinator
│ └── FlowCoordinator
│
├── FlowNavigationUI
│ └── FlowNavigationContainer
│
├── FlowNavigationGuard
│ └── RouteGuard
│
├── FlowNavigationDeepLink
│ └── DeepLinkParser
│
├── FlowNavigationUIKit
│ └── UIKit bridge
│
└── FlowNavigationPersistence
└── Navigation state persistence



---

# Installation

使用 **Swift Package Manager**

Xcode → **File → Add Package Dependencies**

git@github.com:Girlkiller/FlowNavigation.git

选择需要的模块：

FlowNavigationCore
FlowNavigationCoordinator
FlowNavigationUI
FlowNavigationGuard
FlowNavigationDeepLink
FlowNavigationUIKit
FlowNavigationPersistence



---

# Basic Usage

## 1 定义 Route

Host App 或 SDK 可以扩展 `RouteID` 定义自己的路由。

```swift
import FlowNavigationCore

public extension RouteID {

    static let home = RouteID("home")
    static let profile = RouteID("profile")
    static let settings = RouteID("settings")

}


## 2 注册页面

每个模块通过 RouteModule 注册自己的页面。

import SwiftUI
import FlowNavigationCore

struct MyAppModule: RouteModule {

    static let moduleID = "MyAppModule"

    static func register(into registry: RouteRegistry) {

        registry.register(
            RouteDescriptor(
                id: .home
            ) {
                AnyView(Text("Home Page"))
            }
        )

        registry.register(
            RouteDescriptor(
                id: .profile
            ) {
                AnyView(Text("Profile Page"))
            }
        )

        registry.register(
            RouteDescriptor(
                id: .settings
            ) {
                AnyView(Text("Settings Page"))
            }
        )

    }

}

## 3 初始化导航系统

在 Host App 中初始化。

import SwiftUI
import FlowNavigationCore
import FlowNavigationCoordinator
import FlowNavigationUI

@main
struct FlowNavigationApp: App {

    @StateObject private var registry: RouteRegistry
    @StateObject private var coordinator: FlowCoordinator

    init() {

        let registry = RouteRegistry()

        // 注册模块页面
        registry.registerModule(MyAppModule.self)

        let initialState = TabNavigationState(
            selectedTab: "home",
            tabs: ["home", "profile", "settings"]
        )

        let coordinator = FlowCoordinator(
            registry: registry,
            initialState: initialState
        )

        _registry = StateObject(wrappedValue: registry)
        _coordinator = StateObject(wrappedValue: coordinator)

    }

    var body: some Scene {

        WindowGroup {

            FlowNavigationContainer(
                coordinator: coordinator,
                registry: registry
            ) {

                Text("Root View")

            }
            .environmentObject(coordinator)

        }

    }

}


Navigation

在任意 SwiftUI 页面：

@EnvironmentObject
var coordinator: FlowCoordinator

Push
coordinator.push(.profile)

Pop
coordinator.pop()

Pop To Root
coordinator.popToRoot()

Sheet Navigation
coordinator.present(.settings)

支持 Sheet 内 NavigationStack

coordinator.present(.profile, initialStack: [.profile])
Dismiss
coordinator.dismiss(.profile)
Route Guard

用于：

登录拦截

权限控制

Feature Flag

示例：

import FlowNavigationGuard

class AuthGuard: RouteGuard {

    func canNavigate(to route: RouteID) async -> Bool {

        if !UserSession.shared.isLoggedIn {
            return false
        }

        return true
    }

}

注册：

FlowCoordinator(
    registry: registry,
    initialState: initialState,
    guards: [AuthGuard()]
)

当 Guard 拦截时，可以跳转登录页。

DeepLink

示例：

myapp://profile

解析：

import FlowNavigationDeepLink

let parser = DeepLinkParser(
    routeMap: [
        "/profile": .profile
    ]
)

if let route = parser.parse(url: url) {
    coordinator.push(route)
}
UIKit Support

如果需要使用 UIKit 页面：

registry.register(
    RouteDescriptor(
        id: .profile
    ) {
        ProfileViewController()
    }
)

FlowNavigation 会自动包装为 SwiftUI View。

Multi Module / SDK Navigation

FlowNavigation 设计用于 多个 SDK 共享同一个导航系统。

SDK 可以直接调用：

NavigationEnvironment.shared.coordinator?.push(.profile)

或者注册自己的页面：

NavigationEnvironment.shared.registry.registerModule(MySDKModule.self)
Example Project

仓库中包含 Demo App：

DemoApp/

展示：

Tab Navigation

Push

Sheet

Guard

DeepLink

UIKit Page

License

MIT License

