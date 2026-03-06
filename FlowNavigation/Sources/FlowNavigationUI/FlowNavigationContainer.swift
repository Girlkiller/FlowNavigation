//
//  FlowNavigationContainer.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/3.
//

import SwiftUI
import FlowNavigationCore
import FlowNavigationCoordinator

@MainActor
public struct FlowNavigationContainer<Root: View>: View {

    @ObservedObject var coordinator: FlowCoordinator
    let registry: RouteRegistry
    let root: () -> Root

    // MARK: - Init
    public init(coordinator: FlowCoordinator,
                registry: RouteRegistry,
                @ViewBuilder root: @escaping () -> Root) {
        self.coordinator = coordinator
        self.registry = registry
        self.root = root
    }

    // MARK: - Body
    public var body: some View {
        TabView(selection: $coordinator.state.selectedTab) {
            ForEach(tabs, id: \.self) { tab in
                tabView(for: tab)
            }
        }
    }

    // MARK: - Tabs Helper
    private var tabs: [String] {
        Array(coordinator.state.stacks.keys).sorted()
    }

    // MARK: - Tab View
    @ViewBuilder
    private func tabView(for tab: String) -> some View {
        NavigationStack(path: stackBinding(for: tab)) {
            root()
                .navigationDestination(for: RouteID.self) { id in
                    registry.view(for: id)
                }
        }
        .tabItem { Text(tab.capitalized) }
        .tag(tab)
        .sheet(item: sheetBinding(for: tab)) { sheetID in
            sheetView(for: sheetID)
        }
    }

    // MARK: - Stack Binding
    private func stackBinding(for tab: String) -> Binding<[RouteID]> {
        Binding(
            get: { coordinator.state.stacks[tab] ?? [] },
            set: { coordinator.state.stacks[tab] = $0 }
        )
    }

    // MARK: - Sheet Binding
    private func sheetBinding(for tab: String) -> Binding<RouteID?> {
        Binding(
            get: { coordinator.state.sheets[tab] ?? nil },
            set: { coordinator.state.sheets[tab] = $0 }
        )
    }

    // MARK: - Sheet View
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

    // MARK: - Sheet Stack Binding
    private func sheetStackBinding(for sheetID: RouteID) -> Binding<[RouteID]> {
        Binding(
            get: { coordinator.currentStack(for: sheetID) },
            set: { coordinator.state.presentedStacks[sheetID] = $0 }
        )
    }
}
