//
//  File.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/20.
//

import SwiftUI

public struct NavBarItem: Identifiable {
    public let id = UUID()
    public let view: AnyView

    public init(view: AnyView) {
        self.view = view
    }
}

public struct NavigationBarConfig {

    // 基础
    public var hidden: Bool = false
    public var title: String? = nil
    public var tintColor: Color = .black

    // 系统行为
    public var hidesBackButton: Bool = false

    // 左右按钮（支持多个）
    public var leadingItems: [NavBarItem] = []
    public var trailingItems: [NavBarItem] = []

    // 完全自定义
    public var customBar: AnyView? = nil
    public var customBarHeight: CGFloat = 88.0

    public init(hidden: Bool = false, title: String? = nil, tintColor: Color = .black, hidesBackButton: Bool = false, leadingItems: [NavBarItem] = [], trailingItems: [NavBarItem] = [], customBar: AnyView? = nil, customBarHeight: CGFloat = 88.0) {
        self.hidden = hidden
        self.title = title
        self.tintColor = tintColor
        self.hidesBackButton = hidesBackButton
        self.leadingItems = leadingItems
        self.trailingItems = trailingItems
        self.customBar = customBar
        self.customBarHeight = customBarHeight
    }
}
