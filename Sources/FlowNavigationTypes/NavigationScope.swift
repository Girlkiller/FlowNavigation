//
//  File.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/29.
//

import Foundation

public enum NavigationScope: Equatable {

    /// 默认：自动选择（present > tab）
    case automatic

    /// 强制在当前 tab stack
    case tab

    /// 强制在当前 active present
    case present

    /// 指定某个 present
    case specificPresent(RouteID)
}
