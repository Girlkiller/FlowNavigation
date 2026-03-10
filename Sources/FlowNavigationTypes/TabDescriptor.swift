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

    public let badge: Int?

    public let rootRoute: RouteID?

    public let action: (() -> Void)?

    public init(
        id: String,
        title: String,
        icon: TabIcon,
        style: TabStyle = .normal,
        badge: Int? = nil,
        rootRoute: RouteID? = nil,
        action: (() -> Void)? = nil
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.style = style
        self.badge = badge
        self.rootRoute = rootRoute
        self.action = action
    }

    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case icon
        case style
        case badge
        case rootRoute
    }

    // MARK: - Decodable

    public init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        icon = try container.decode(TabIcon.self, forKey: .icon)
        style = try container.decode(TabStyle.self, forKey: .style)

        badge = try container.decodeIfPresent(Int.self, forKey: .badge)
        rootRoute = try container.decodeIfPresent(RouteID.self, forKey: .rootRoute)

        // action 不能 decode
        action = nil
    }

    // MARK: - Encodable

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(icon, forKey: .icon)
        try container.encode(style, forKey: .style)

        try container.encodeIfPresent(badge, forKey: .badge)
        try container.encodeIfPresent(rootRoute, forKey: .rootRoute)
    }
}

extension TabDescriptor: Equatable {
    public static func == (lhs: TabDescriptor, rhs: TabDescriptor) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


extension TabDescriptor {

    public init(config: RemoteTabConfig) {
        self.id = config.id
        self.title = config.title
        self.icon = .system(config.icon)
        self.style = .normal
        self.badge = nil
        self.rootRoute = nil
        self.action = nil
    }
}
