//
//  FlowCoordinator.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/3.
//

import SwiftUI
import FlowNavigationCore
import FlowNavigationGuard
import Combine

@MainActor
public final class FlowCoordinator: ObservableObject {

    private let registry: RouteRegistry
    private let guards: [RouteGuard]

    @Published public var state: TabNavigationState

    public init(registry: RouteRegistry, initialState: TabNavigationState, guards: [RouteGuard] = []) {
        self.registry = registry
        self.state = initialState
        self.guards = guards
    }

    // MARK: - Tab navigation
    public func selectTab(_ tab: String) { state.selectedTab = tab }
    public func push(_ id: RouteID) {
        Task {
            for g in guards {
                if !(await g.canNavigate(to: id)) {
                    if let auth = g as? AuthGuard {
                        self.present(auth.loginRouteID())
                    }
                    return
                }
            }
            state.stacks[state.selectedTab]?.append(id)
        }
    }

    public func pop() { state.stacks[state.selectedTab]?.popLast() }
    public func popToRoot() { state.stacks[state.selectedTab]?.removeAll() }

    // MARK: - Present / FullScreen with stack
    public func present(_ id: RouteID, initialStack: [RouteID]? = nil) {
        state.presentedStacks[id] = initialStack ?? [id]
        state.sheets[state.selectedTab] = id
    }

    public func dismiss(_ id: RouteID) {
        state.presentedStacks[id] = nil
        if state.sheets[state.selectedTab] == id { state.sheets[state.selectedTab] = nil }
        if state.fullScreens[state.selectedTab] == id { state.fullScreens[state.selectedTab] = nil }
    }

    public func pushInPresent(_ presentID: RouteID, route: RouteID) {
        state.presentedStacks[presentID]?.append(route)
    }

    public func popInPresent(_ presentID: RouteID) {
        state.presentedStacks[presentID]?.popLast()
    }

    public func currentStack(for presentID: RouteID) -> [RouteID] {
        state.presentedStacks[presentID] ?? []
    }
}
