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
public final class FlowCoordinator: ObservableObject, Router {

    // MARK: - Dependencies

    let registry: RouteRegistry
    private let guards: [RouteGuard]

    // MARK: - State

    @Published public var state: TabNavigationState

    // MARK: - Init

    public init(
        registry: RouteRegistry,
        initialState: TabNavigationState,
        guards: [RouteGuard] = []
    ) {
        self.registry = registry
        self.state = initialState
        self.guards = guards
    }

    // MARK: - Guard Check

    func canNavigate(to id: RouteID) async -> Bool {

        guard let descriptor = registry.descriptor(for: id) else {
            print("cannot navigate routeID: \(id)")
            return false
        }

        guard !descriptor.skipGuards else {
            print("skip guard routeID: \(id)")
            return true
        }

        let guards = descriptor.guards + guards

        for g in guards {

            let result = await g.evaluate(to: id)

            switch result {

            case .allow:
                continue

            case .deny:
                return false

            case .redirect(let redirect):
                handleRedirect(redirect)
                return false
            }
        }

        return true
    }

    func handleRedirect(_ redirect: NavigationRedirect) {

        switch redirect.style {

        case .push:
            push(redirect.routeID)
        case .present(let style):
            switch style {
            case .sheet(let allowsDismiss):
                present(
                    redirect.routeID,
                    style: .sheet(allowsDismiss: allowsDismiss)
                )
            case .fullScreen(let transparent):
                present(
                    redirect.routeID,
                    style: .fullScreen(transparent: transparent)
                )
            }
        }
    }

    private func currentActivePresentedID() -> RouteID? {
        if let id = state.presentationOrder.last {
            return id
        }

        // fullScreen 优先
        if let id = state.fullScreens[state.selectedTab] {
            return id
        }

        // 再看 sheet
        if let id = state.sheets[state.selectedTab] {
            return id
        }

        return nil
    }

    // MARK: - Tab Navigation

    public func selectTab(_ tab: String) {
        state.selectedTab = tab
    }

    // MARK: - Push

    public func push(
        _ id: RouteID,
        scope: NavigationScope = .automatic
    ) {

        Task {

            guard await canNavigate(to: id) else { return }

            switch scope {

            case .automatic:
                if let presentID = currentActivePresentedID() {
                    state.presentedStacks[presentID, default: [presentID]].append(id)
                } else {
                    state.stacks[state.selectedTab, default: []].append(id)
                }

            case .tab:
                state.stacks[state.selectedTab, default: []].append(id)

            case .present:
                guard let presentID = currentActivePresentedID() else { return }
                state.presentedStacks[presentID, default: [presentID]].append(id)

            case .specificPresent(let presentID):
                state.presentedStacks[presentID, default: [presentID]].append(id)
            }
        }
    }

    // MARK: - Pop

    @discardableResult
    public func pop(scope: NavigationScope = .automatic) -> RouteID? {

        switch scope {

        case .automatic:
            if let presentID = currentActivePresentedID() {
                return state.presentedStacks[presentID]?.popLast()
            }
            return state.stacks[state.selectedTab]?.popLast()

        case .tab:
            return state.stacks[state.selectedTab]?.popLast()

        case .present:
            guard let presentID = currentActivePresentedID() else { return nil }
            return state.presentedStacks[presentID]?.popLast()

        case .specificPresent(let presentID):
            return state.presentedStacks[presentID]?.popLast()
        }
    }

    public func popToRoot(scope: NavigationScope = .automatic) {

        switch scope {

        case .automatic:
            if let presentID = currentActivePresentedID() {
                state.presentedStacks[presentID] = [presentID]
            } else {
                state.stacks[state.selectedTab]?.removeAll()
            }

        case .tab:
            state.stacks[state.selectedTab]?.removeAll()

        case .present:
            guard let presentID = currentActivePresentedID() else { return }
            state.presentedStacks[presentID] = [presentID]

        case .specificPresent(let presentID):
            state.presentedStacks[presentID] = [presentID]
        }
    }

    // MARK: - Present
    public func present(
        _ id: RouteID,
        style: PresentStyle = .sheet(allowsDismiss: true),
        initialStack: [RouteID]? = nil
    ) {

        Task {

            guard await canNavigate(to: id) else { return }

            let stack = initialStack ?? [id]

            state.presentedStacks[id] = stack
            state.presentStyles[id] = style
            state.presentationOrder.append(id)

            switch style {

            case .sheet:

                state.sheets[state.selectedTab] = id

            case .fullScreen:

                state.fullScreens[state.selectedTab] = id
            }
        }
    }

    // MARK: - Dismiss

    public func dismiss(_ id: RouteID) {

        state.presentedStacks[id] = nil
        state.presentStyles.removeValue(forKey: id)
        state.presentationOrder.removeAll { $0 == id }

        if state.sheets[state.selectedTab] == id {
            state.sheets[state.selectedTab] = nil
        }

        if state.fullScreens[state.selectedTab] == id {
            state.fullScreens[state.selectedTab] = nil
        }
    }

    // MARK: - Push in Present

    public func pushInPresent(
        _ presentID: RouteID,
        route: RouteID
    ) {

        state.presentedStacks[presentID, default: [presentID]].append(route)
    }

    // MARK: - Pop in Present

    @discardableResult
    public func popInPresent(_ presentID: RouteID) -> RouteID? {

        state.presentedStacks[presentID]?.popLast()
    }

    // MARK: - Query Current Stack

    public func currentStack(for presentID: RouteID) -> [RouteID] {

        state.presentedStacks[presentID] ?? []
    }

    // MARK: - Ensure Stack

    public func ensurePresentedStack(for id: RouteID) {

        if state.presentedStacks[id] == nil {
            state.presentedStacks[id] = [id]
        }
    }

    // MARK: - DeepLink

    public func navigate(to url: URL, style: NavigationStyle = .push, scope: NavigationScope = .automatic) async {

        await navigate(to: url, style: style, parsers: [], scope: scope)
    }

    public func presentStyle(for id: RouteID) -> PresentStyle {

        state.presentStyles[id] ?? .sheet()
    }

    public func currentTopRoute(for tab: String) -> RouteID {
        state.stacks[tab]?.last ?? RouteID(tab)
    }
}
