//
//  FlowCoordinator.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/3.
//

import SwiftUI
import FlowNavigationTypes
import FlowNavigationCore
import FlowNavigationGuard
import Combine

@MainActor
public final class FlowCoordinator: ObservableObject {

    let registry: RouteRegistry
    private let guards: [RouteGuard]

    @Published public var state: TabNavigationState

    public init(registry: RouteRegistry, initialState: TabNavigationState, guards: [RouteGuard] = []) {
        self.registry = registry
        self.state = initialState
        self.guards = guards
    }

    // MARK: - 检查 Guard
    private func canNavigate(to id: RouteID) async -> Bool {
        guard let descriptor = registry.descriptor(for: id) else { return true }
        let guards = descriptor.guards + guards
        for g in guards {
            if !(await g.canNavigate(to: id)) {
                if let auth = g as? AuthGuard {
                    present(auth.loginRouteID())
                }
                return false
            }
        }
        return true
    }

    // MARK: - Tab navigation
    public func selectTab(_ tab: String) {
        state.selectedTab = tab
    }
    
    public func push(_ id: RouteID) {
        Task {
            guard await canNavigate(to: id) else { return }
            state.stacks[state.selectedTab]?.append(id)
        }
    }

    @discardableResult
    public func pop() -> RouteID? {
        state.stacks[state.selectedTab]?.popLast()
    }
    
    public func popToRoot() {
        state.stacks[state.selectedTab]?.removeAll()
    }

    // MARK: - Present / FullScreen with stack
    public func present(_ id: RouteID, initialStack: [RouteID]? = nil) {
        Task {
            guard await canNavigate(to: id) else { return }
            state.presentedStacks[id] = initialStack ?? [id]
            state.sheets[state.selectedTab] = id
        }
    }

    public func dismiss(_ id: RouteID) {
        state.presentedStacks[id] = nil
        if state.sheets[state.selectedTab] == id { state.sheets[state.selectedTab] = nil }
        if state.fullScreens[state.selectedTab] == id { state.fullScreens[state.selectedTab] = nil }
    }

    public func pushInPresent(_ presentID: RouteID, route: RouteID) {
        state.presentedStacks[presentID]?.append(route)
    }

    @discardableResult
    public func popInPresent(_ presentID: RouteID) -> RouteID? {
        state.presentedStacks[presentID]?.popLast()
    }

    public func currentStack(for presentID: RouteID) -> [RouteID] {
        state.presentedStacks[presentID] ?? []
    }
}
