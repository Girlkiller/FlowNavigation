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

    private var queue: [NavigationAction] = []
    private var isRunning: Bool = false

    private var dismissCompletionActions: [RouteID: NavigationAction] = [:]

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

    public func perform(_ action: NavigationAction) {
        queue.append(action)

        if !isRunning {
            Task { await run() }
        }
    }

    private func run() async {

        guard !isRunning else { return }
        isRunning = true

        while !queue.isEmpty {

            let action = queue.removeFirst()
            await execute(action)
        }

        isRunning = false
    }

    func execute(_ action: NavigationAction) async {

        switch action {

        case let .push(id, scope):
            push(id, scope: scope)

        case let .pop(scope):
            _ = pop(scope: scope)

        case let .popToRoot(scope):
            popToRoot(scope: scope)

        case let .present(id, style, stack):
            await present(id, style: style, initialStack: stack)

        case let .dismiss(id):
            dismiss(id)

        case let .sequence(actions):
            for a in actions {
                await execute(a)
            }

        case let .replaceAll(with, style):
            await replaceAll(with: with, style: style)

        case let .replaceTop(id, scope):
            await replaceTop(id, scope: scope)

        case let .dismissAndPush(dismissID, pushID, scope):
            setDismissCompletion(
                for: dismissID,
                action: .push(pushID, scope)
            )

            dismiss(dismissID)

        case let .dismissAndPresent(dismissID, presentID, style, stack):
            setDismissCompletion(
                for: dismissID,
                action: .present(presentID, style, initialStack: stack)
            )

            dismiss(dismissID)

        case let .navigate(url, style, scope):
            await navigate(to: url, style: style, scope: scope)
        }
    }

    public func setDismissCompletion(
        for id: RouteID,
        action: NavigationAction
    ) {
        dismissCompletionActions[id] = action
    }

    public func handleDismissCompletion(for id: RouteID) {

        guard let action = dismissCompletionActions[id] else { return }

        dismissCompletionActions.removeValue(forKey: id)

        perform(action)
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

    private func push(
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
    private func pop(scope: NavigationScope = .automatic) -> RouteID? {

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

    private func popToRoot(scope: NavigationScope = .automatic) {

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
    private func present(
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

    private func dismiss(_ id: RouteID) {

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

    private func pushInPresent(
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

    private func replaceTop(
        _ id: RouteID,
        scope: NavigationScope
    ) {
        switch scope {

        case .automatic:
            if let presentID = currentActivePresentedID() {
                var stack = state.presentedStacks[presentID] ?? [presentID]
                _ = stack.popLast()
                stack.append(id)
                state.presentedStacks[presentID] = stack
            } else {
                var stack = state.stacks[state.selectedTab] ?? []
                _ = stack.popLast()
                stack.append(id)
                state.stacks[state.selectedTab] = stack
            }

        case .tab:
            var stack = state.stacks[state.selectedTab] ?? []
            _ = stack.popLast()
            stack.append(id)
            state.stacks[state.selectedTab] = stack

        case .present:
            guard let presentID = currentActivePresentedID() else { return }
            var stack = state.presentedStacks[presentID] ?? [presentID]
            _ = stack.popLast()
            stack.append(id)
            state.presentedStacks[presentID] = stack

        case .specificPresent(let presentID):
            var stack = state.presentedStacks[presentID] ?? [presentID]
            _ = stack.popLast()
            stack.append(id)
            state.presentedStacks[presentID] = stack
        }
    }

    // MARK: - REPLACE ALL

    private func replaceAll(
        with id: RouteID,
        style: PresentStyle
    ) async {
        let presented = state.presentationOrder

        for pid in presented.reversed() {
            dismiss(pid)
        }

        state.stacks[state.selectedTab]?.removeAll()

        await present(id, style: style, initialStack: nil)
    }
}

extension FlowCoordinator {

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

    public func presentStyle(for id: RouteID) -> PresentStyle {

        state.presentStyles[id] ?? .sheet()
    }

    public func currentTopRoute(for tab: String) -> RouteID {
        state.stacks[tab]?.last ?? RouteID(tab)
    }
}
