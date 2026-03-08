//
//  RouteID.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/3.
//

import Foundation

public struct RouteID: Hashable, Codable, Sendable, ExpressibleByStringLiteral {

    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: StringLiteralType) {
        self.rawValue = value
    }
}

extension RouteID: Identifiable {
    public var id: String {
        self.rawValue
    }
}
