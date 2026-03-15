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

    public init(
        coordinator: FlowCoordinator,
        registry: RouteRegistry,
        @ViewBuilder root: @escaping (String) -> Root
    ) {
        self.coordinator = coordinator
        self.registry = registry
        self.root = root
    }

    public var body: some View {

        ZStack(alignment: .bottom) {

            TabView(selection: $coordinator.state.selectedTab) {

                ForEach(visibleTabs) { tab in
                    tabView(for: tab)
                }
            }

            centerButton
        }
        .ignoresSafeArea(.keyboard)
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

            Color.clear
                .tabItem { EmptyView() }
                .tag(tab.id)

        } else {

            NavigationStack(path: stackBinding(for: tab.id)) {

                root(tab.id)

                    .navigationDestination(for: RouteID.self) { id in
                        registry.view(for: id)
                    }
            }
            .tabItem {
                tabItem(tab)
            }
            .tag(tab.id)

            // Sheet
            .sheet(item: sheetBinding(for: tab.id)) { sheetID in

                let style = coordinator.presentStyle(for: sheetID)

                modalNavigation(
                    for: sheetID,
                    showClose: !style.allowsDismiss,
                    transparent: style.isTransparent
                )
                .interactiveDismissDisabled(!style.allowsDismiss)
            }

            // FullScreen
            .fullScreenCover(item: fullScreenBinding(for: tab.id)) { id in
                let style = coordinator.presentStyle(for: id)

                ZStack {
                    if #available(iOS 16.4, *), style.isTransparent {
                        modalNavigation(
                            for: id,
                            showClose: !style.allowsDismiss,
                            transparent: style.isTransparent
                        )
                        .presentationBackground(.clear)
                        .ignoresSafeArea()
                    } else {
                        modalNavigation(
                            for: id,
                            showClose: !style.allowsDismiss,
                            transparent: style.isTransparent
                        )
                    }
                }
            }
        }
    }

    // MARK: Tab Item

    private func tabItem(_ tab: TabDescriptor) -> some View {

        ZStack(alignment: .topTrailing) {

            VStack {

                iconView(tab.icon)

                Text(tab.title)
                    .font(.caption)
            }

            if let badge = tab.badge, badge > 0 {

                Text("\(badge)")
                    .font(.system(size: 10))
                    .padding(4)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .offset(x: 10, y: -5)
            }
        }
    }

    // MARK: Center Button

    @ViewBuilder
    private var centerButton: some View {

        if let tab = centerTab {

            Button {

                if let action = tab.action {
                    action()
                } else {
                    coordinator.state.selectedTab = tab.id
                }

            } label: {

                iconView(tab.icon)
                    .frame(width: 64, height: 64)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            .offset(y: -30)
            .animation(.spring(), value: coordinator.state.selectedTab)
        }
    }

    // MARK: Icon

    @ViewBuilder
    private func iconView(_ icon: TabIcon) -> some View {

        switch icon {

        case .system(let name):

            Image(systemName: name)

        case .asset(let name):

            Image(name)

        case .remote(let url):

            AsyncImage(url: url) { image in

                image
                    .resizable()
                    .scaledToFit()

            } placeholder: {

                ProgressView()
            }
        }
    }

    // MARK: Tab Stack Binding

    private func stackBinding(for tab: String) -> Binding<[RouteID]> {

        Binding(
            get: {
                coordinator.state.stacks[tab] ?? []
            },
            set: {
                coordinator.state.stacks[tab] = $0
            }
        )
    }

    // MARK: Sheet Binding

    private func sheetBinding(for tab: String) -> Binding<RouteID?> {

        Binding(
            get: {
                coordinator.state.sheets[tab] ?? nil
            },
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

    // MARK: FullScreen Binding

    private func fullScreenBinding(for tab: String) -> Binding<RouteID?> {

        Binding(
            get: {
                coordinator.state.fullScreens[tab]  ?? nil
            },
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
    private func modalNavigation(
        for id: RouteID,
        showClose: Bool,
        transparent: Bool
    ) -> some View {

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

    // MARK: Presented Stack Binding

    private func presentedStackBinding(
        for id: RouteID,
        root: RouteID
    ) -> Binding<[RouteID]> {

        Binding(

            get: {

                let stack = coordinator.currentStack(for: id)

                return Array(stack.dropFirst())
            },

            set: { newValue in

                coordinator.state.presentedStacks[id] = [root] + newValue
            }
        )
    }
}
