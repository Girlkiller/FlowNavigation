//
//  FlowNavigationContainer.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/3.
//

import SwiftUI
import FlowNavigationCore
import FlowNavigationCoordinator
import FlowNavigationTypes

@MainActor
public struct FlowNavigationContainer<Root: View>: View {

    @ObservedObject var coordinator: FlowCoordinator
    let registry: RouteRegistry
    let root: (String) -> Root
    var tabBarStyle: TabBarStyle = TabBarStyle()
    var centerButtonStyle: ((AnyView) -> AnyView)?

    @State private var tabBarHidden: Bool = false

    public init(
        coordinator: FlowCoordinator,
        registry: RouteRegistry,
        tabBarStyle: TabBarStyle = TabBarStyle(),
        @ViewBuilder root: @escaping (String) -> Root,
        centerButtonStyle: ((AnyView) -> AnyView)? = nil
    ) {
        self.coordinator = coordinator
        self.registry = registry
        self.root = root
        self.tabBarStyle = tabBarStyle
        self.centerButtonStyle = centerButtonStyle
        UITabBar.appearance().isHidden = true
    }

    public var body: some View {
        GeometryReader { proxy in
            let bottomSafe = proxy.safeAreaInsets.bottom
            let tabBarStyle = {
                var style = self.tabBarStyle
                style.bottomSafeArea = bottomSafe
                return style
            }()
            ZStack(alignment: .bottom) {

                // MARK: Content
                TabView(selection: $coordinator.state.selectedTab) {
                    ForEach(visibleTabs) { tab in
                        tabView(for: tab)
                            .ignoresSafeArea(.all, edges: .bottom) // ⚡️忽略底部预留
                    }
                }

                // MARK: Custom TabBar
                CustomTabBar(
                    tabs: visibleTabs,
                    selectedTab: $coordinator.state.selectedTab,
                    centerTab: centerTab,
                    hidden: tabBarHidden,
                    centerButtonStyle: centerButtonStyle,
                    style: tabBarStyle,
                    onTabSelected: { id in coordinator.state.selectedTab = id },
                    onCenterTap: {
                        if let action = centerTab?.action { action() }
                        else if let id = centerTab?.id { coordinator.state.selectedTab = id }
                    }
                )
                .padding(.bottom, 0) // ⚡️背景自带 safeArea
            }
            .ignoresSafeArea(.keyboard)
            .ignoresSafeArea(.all)
        }
    }

    // MARK: Tabs
    private var visibleTabs: [TabDescriptor] {
        coordinator.state.tabs.filter { $0.style != .hidden }
    }

    private var centerTab: TabDescriptor? {
        coordinator.state.tabs.first { $0.style == .centerButton }
    }

    // MARK: Tab View
    @ViewBuilder
    private func tabView(for tab: TabDescriptor) -> some View {
        if tab.style == .centerButton {
            Color.clear.tag(tab.id)
        } else {
            NavigationStack(path: stackBinding(for: tab.id)) {

                root(tab.id)
                    .toolbar(.hidden, for: .tabBar) // ⚡️隐藏系统 tabbar
                    .navigationDestination(for: RouteID.self) { id in
                        let shouldHide = registry.descriptor(for: id)?.hidesTabBar ?? false
                        registry.view(for: id)
                            .toolbar(shouldHide ? .hidden : .visible, for: .tabBar)
                            .onAppear { updateTabBarVisibility(hide: shouldHide) }
                    }
            }
            .onChange(of: coordinator.state.stacks[tab.id] ?? []) { newStack in
                handleStackChange(newStack: newStack)
            }
            .tag(tab.id)
            // Sheet
            .sheet(item: sheetBinding(for: tab.id)) { sheetID in
                let style = coordinator.presentStyle(for: sheetID)
                modalNavigation(for: sheetID, showClose: !style.allowsDismiss, transparent: style.isTransparent)
                    .interactiveDismissDisabled(!style.allowsDismiss)
            }
            // FullScreen
            .fullScreenCover(item: fullScreenBinding(for: tab.id)) { id in
                let style = coordinator.presentStyle(for: id)
                ZStack {
                    if #available(iOS 16.4, *), style.isTransparent {
                        modalNavigation(for: id, showClose: !style.allowsDismiss, transparent: style.isTransparent)
                            .presentationBackground(.clear)
                            .ignoresSafeArea()
                    } else {
                        modalNavigation(for: id, showClose: !style.allowsDismiss, transparent: style.isTransparent)
                    }
                }
            }
        }
    }

    // MARK: 手势联动
    private func handleStackChange(newStack: [RouteID]) {
        let isRoot = newStack.isEmpty
        withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.85)) {
            tabBarHidden = !isRoot
        }
    }

    private func updateTabBarVisibility(hide: Bool) {
        guard tabBarHidden != hide else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            tabBarHidden = hide
        }
    }

    // MARK: Stack Binding
    private func stackBinding(for tab: String) -> Binding<[RouteID]> {
        Binding(get: { coordinator.state.stacks[tab] ?? [] },
                set: { coordinator.state.stacks[tab] = $0 })
    }

    private func sheetBinding(for tab: String) -> Binding<RouteID?> {
        Binding(
            get: { coordinator.state.sheets[tab] ?? nil },
            set: { newValue in
                if let value = newValue {
                    coordinator.ensurePresentedStack(for: value)
                    coordinator.state.sheets[tab] = value
                } else {
                    coordinator.state.sheets.removeValue(forKey: tab)
                }
            }
        )
    }

    private func fullScreenBinding(for tab: String) -> Binding<RouteID?> {
        Binding(
            get: { coordinator.state.fullScreens[tab] ?? nil },
            set: { newValue in
                if let value = newValue {
                    coordinator.ensurePresentedStack(for: value)
                    coordinator.state.fullScreens[tab] = value
                } else {
                    coordinator.state.fullScreens.removeValue(forKey: tab)
                }
            }
        )
    }

    // MARK: Modal Navigation
    @ViewBuilder
    private func modalNavigation(for id: RouteID, showClose: Bool, transparent: Bool) -> some View {
        let stack = coordinator.currentStack(for: id)
        if stack.isEmpty {
            Text("Empty Stack")
        } else {
            let rootID = stack.first!
            NavigationStack(path: presentedStackBinding(for: id, root: rootID)) {
                registry.view(for: rootID)
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        if showClose {
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    coordinator.dismiss(id)
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(transparent ? .white : .black)
                                }
                            }
                        }
                    }
                    .navigationDestination(for: RouteID.self) { route in
                        registry.view(for: route)
                    }
            }
            .id(id)
        }
    }

    private func presentedStackBinding(for id: RouteID, root: RouteID) -> Binding<[RouteID]> {
        Binding(
            get: { Array(coordinator.currentStack(for: id).dropFirst()) },
            set: { coordinator.state.presentedStacks[id] = [root] + $0 }
        )
    }
}
