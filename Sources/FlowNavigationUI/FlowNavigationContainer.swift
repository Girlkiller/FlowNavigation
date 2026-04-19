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
    @State private var currentSheetID: RouteID?
    @State private var currentFullScreenID: RouteID?

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

                TabView(selection: $coordinator.state.selectedTab) {
                    ForEach(visibleTabs) { tab in
                        tabView(for: tab)
                            .ignoresSafeArea(.all, edges: .bottom)
                    }
                }

                CustomTabBar(
                    tabs: visibleTabs,
                    selectedTab: $coordinator.state.selectedTab,
                    centerTab: centerTab,
                    hidden: tabBarHidden,
                    centerButtonStyle: centerButtonStyle,
                    style: tabBarStyle,
                    onTabSelected: { coordinator.state.selectedTab = $0 },
                    onCenterTap: {
                        if let action = centerTab?.action { action() }
                        else if let id = centerTab?.id { coordinator.state.selectedTab = id }
                    }
                )
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

                buildView(
                    root(tab.id),
                    route: currentRoute(for: tab.id)
                )
                .toolbar(.hidden, for: .tabBar)

                .navigationDestination(for: RouteID.self) { id in

                    buildView(
                        registry.view(for: id),
                        route: id
                    )
                    .toolbar(.hidden, for: .tabBar)
                    .onAppear {
                        let shouldHide = registry.descriptor(for: id)?.hidesTabBar ?? false
                        updateTabBarVisibility(hide: shouldHide)
                    }
                }
            }
            .onChange(of: coordinator.state.stacks[tab.id] ?? []) {
                handleStackChange(newStack: $0)
            }
            .tag(tab.id)

            .sheet(item: sheetBinding(for: tab.id), onDismiss: {
                if let id = currentSheetID {
                    coordinator.handleDismissCompletion(for: id)
                    currentSheetID = nil
                }
            }) { sheetID in
                let style = coordinator.presentStyle(for: sheetID)
                modalNavigation(for: sheetID, showClose: !style.allowsDismiss, transparent: style.isTransparent)
                    .interactiveDismissDisabled(!style.allowsDismiss)
                    .onAppear {
                        currentSheetID = sheetID
                    }
            }

            .fullScreenCover(item: fullScreenBinding(for: tab.id), onDismiss: {
                if let id = currentFullScreenID {
                    coordinator.handleDismissCompletion(for: id)
                    currentFullScreenID = nil
                }
            }) { id in
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
                .onAppear {
                    currentFullScreenID = id
                }
            }
        }
    }

    // MARK: Modal
    @ViewBuilder
    private func modalNavigation(for id: RouteID, showClose: Bool, transparent: Bool) -> some View {

        let stack = coordinator.currentStack(for: id)

        if stack.isEmpty {
            Text("Empty Stack")
        } else {
            let rootID = stack.first!

            NavigationStack(path: presentedStackBinding(for: id, root: rootID)) {

                buildView(
                    registry.view(for: rootID),
                    route: rootID
                )

                .navigationDestination(for: RouteID.self) { route in
                    buildView(
                        registry.view(for: route),
                        route: route
                    )
                }
            }
            .id(id)
        }
    }

    // MARK: Core Nav Logic

    private func buildView(_ view: some View, route: RouteID) -> some View {
        let v1 = applySystemNavBar(view, route: route)
        return applyCustomBar(v1, route: route)
    }

    private func applySystemNavBar(_ view: some View, route: RouteID) -> some View {

        guard let config = registry.descriptor(for: route)?.navBar else {
            return AnyView(view)
        }

        if config.customBar != nil {
            return AnyView(view.toolbar(.hidden, for: .navigationBar))
        }

        return AnyView(
            view
                .navigationTitle(config.title ?? "")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(config.hidesBackButton)
                .toolbar {
                    buildToolbar(for: route)
                }
                .toolbar(config.hidden ? .hidden : .visible, for: .navigationBar)
        )
    }

    private func applyCustomBar(_ view: some View, route: RouteID) -> some View {

        guard let config = registry.descriptor(for: route)?.navBar,
              let custom = config.customBar,
              !config.hidden else {
            return AnyView(view)
        }

        return AnyView(
            VStack(spacing: 0) {

                // ✅ 导航栏（占位！）
                custom
                    .frame(height: config.customBarHeight)

                // ✅ 内容
                view
            }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea(edges: .top) // 允许导航栏延伸
        )
    }

    @ToolbarContentBuilder
    private func buildToolbar(for route: RouteID) -> some ToolbarContent {

        if let config = registry.descriptor(for: route)?.navBar,
           !config.hidden,
           config.customBar == nil {

            if !config.leadingItems.isEmpty {
                ToolbarItemGroup(placement: .topBarLeading) {
                    ForEach(config.leadingItems) { $0.view }
                }
            }

            if !config.trailingItems.isEmpty {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    ForEach(config.trailingItems) { $0.view }
                }
            }
        }
    }

    // MARK: Helpers

    private func currentRoute(for tab: String) -> RouteID {
        coordinator.state.stacks[tab]?.last ?? RouteID(tab)
    }

    private func handleStackChange(newStack: [RouteID]) {
        withAnimation(.spring()) {
            tabBarHidden = !newStack.isEmpty
        }
    }

    private func updateTabBarVisibility(hide: Bool) {
        guard tabBarHidden != hide else { return }
        withAnimation(.spring()) {
            tabBarHidden = hide
        }
    }

    private func stackBinding(for tab: String) -> Binding<[RouteID]> {
        Binding(
            get: { coordinator.state.stacks[tab] ?? [] },
            set: { coordinator.state.stacks[tab] = $0 }
        )
    }

    private func sheetBinding(for tab: String) -> Binding<RouteID?> {
        Binding(
            get: { coordinator.state.sheets[tab] ?? nil },
            set: {
                if let value = $0 {
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
            set: {
                if let value = $0 {
                    coordinator.ensurePresentedStack(for: value)
                    coordinator.state.fullScreens[tab] = value
                } else {
                    coordinator.state.fullScreens.removeValue(forKey: tab)
                }
            }
        )
    }

    private func presentedStackBinding(for id: RouteID, root: RouteID) -> Binding<[RouteID]> {
        Binding(
            get: { Array(coordinator.currentStack(for: id).dropFirst()) },
            set: { coordinator.state.presentedStacks[id] = [root] + $0 }
        )
    }
}
