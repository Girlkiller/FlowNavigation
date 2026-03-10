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

    private var visibleTabs: [TabDescriptor] {

        coordinator.state.tabs.filter {
            $0.style != .hidden
        }
    }

    private var centerTab: TabDescriptor? {

        coordinator.state.tabs.first {
            $0.style == .centerButton
        }
    }

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
            .sheet(item: sheetBinding(for: tab.id)) { sheetID in
                sheetView(for: sheetID)
            }
        }
    }

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

    private func sheetBinding(for tab: String) -> Binding<RouteID?> {
        Binding(
            get: { coordinator.state.sheets[tab] ?? nil },
            set: { newValue in
                if let value = newValue {
                    coordinator.state.sheets[tab] = value
                } else {
                    coordinator.state.sheets.removeValue(forKey: tab)
                }
            }
        )
    }

    @ViewBuilder
    private func sheetView(for sheetID: RouteID) -> some View {

        NavigationStack(path: sheetStackBinding(for: sheetID)) {

            if let rootID = coordinator.currentStack(for: sheetID).first {

                registry.view(for: rootID)

            } else {

                Text("Empty Stack")
            }
        }
    }

    private func sheetStackBinding(for sheetID: RouteID) -> Binding<[RouteID]> {

        Binding(
            get: {
                coordinator.currentStack(for: sheetID)
            },
            set: {
                coordinator.state.presentedStacks[sheetID] = $0
            }
        )
    }
}
