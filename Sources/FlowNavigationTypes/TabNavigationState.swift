//
//  TabNavigationState.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/3.
//

import Foundation

public struct TabNavigationState: Codable, Equatable {

    public var selectedTab: String

    public var tabs: [TabDescriptor]

    public var stacks: [String: [RouteID]]

    public var sheets: [String: RouteID?]

    public var fullScreens: [String: RouteID?]

    public var presentedStacks: [RouteID: [RouteID]]

    public init(
        selectedTab: String,
        tabs: [TabDescriptor]
    ) {

        self.selectedTab = selectedTab
        self.tabs = tabs

        self.stacks = [:]
        self.sheets = [:]
        self.fullScreens = [:]
        self.presentedStacks = [:]

        for tab in tabs {

            stacks[tab.id] = []

            sheets[tab.id] = nil

            fullScreens[tab.id] = nil
        }
    }
}
