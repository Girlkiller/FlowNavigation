//
//  File.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/8.
//

import Foundation

public enum TabIcon: Hashable, Codable {

    case system(String)

    case asset(String)

    case remote(URL)
}

public enum TabStyle: Hashable, Codable {

    case normal

    case centerButton

    case hidden
}

public struct TabDescriptor: Identifiable, Hashable, Codable {

    public let id: String
    public let title: String
    public let icon: TabIcon
    public let style: TabStyle

    public init(
        id: String,
        title: String,
        icon: TabIcon,
        style: TabStyle = .normal
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.style = style
    }
}
