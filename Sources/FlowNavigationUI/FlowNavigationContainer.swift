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
    }

    private var visibleTabs: [TabDescriptor] {
        coordinator.state.tabs.filter { $0.style != .hidden && $0.style != .centerButton }
    }

    private var centerTab: TabDescriptor? {
        coordinator.state.tabs.first { $0.style == .centerButton }
    }

    @ViewBuilder
    private func tabView(for tab: TabDescriptor) -> some View {

        NavigationStack(path: stackBinding(for: tab.id)) {

            root(tab.id)
                .navigationDestination(for: RouteID.self) { id in
                    registry.view(for: id)
                }
        }
        .tabItem {

            VStack {

                iconView(tab.icon)

                Text(tab.title)
            }
        }
        .tag(tab.id)
        .sheet(item: sheetBinding(for: tab.id)) { sheetID in
            sheetView(for: sheetID)
        }
    }

    @ViewBuilder
    private var centerButton: some View {

        if let tab = centerTab {

            Button {

                coordinator.state.selectedTab = tab.id

            } label: {

                iconView(tab.icon)
                    .frame(width: 64, height: 64)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .offset(y: -20)
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
                image.resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
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
            set: { coordinator.state.sheets[tab] = $0 }
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
            get: { coordinator.currentStack(for: sheetID) },
            set: { coordinator.state.presentedStacks[sheetID] = $0 }
        )
    }
}
