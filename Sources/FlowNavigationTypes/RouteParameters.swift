//
//  File.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/15.
//

import Foundation

/// 路由参数封装
public struct RouteParameters {
    private let values: [String: Any]

    public init(values: [String: Any] = [:]) {
        self.values = values
    }

    public subscript(key: String) -> String? {
        values[key] as? String
    }

    public func int(for key: String) -> Int? {
        if let value = values[key] as? Int {
            return value
        }
        guard let str = values[key] as? String else { return nil }
        return Int(str)
    }

    public func bool(for key: String) -> Bool? {
        guard let str = (values[key] as? String)?.lowercased() else { return nil }
        return ["true", "1", "yes", "ok"].contains(str)
    }

    public func double(for key: String) -> Double? {
        if let value = values[key] as? Double {
            return value
        }
        guard let str = values[key] as? String else {
            return nil
        }
        return Double(str)
    }
}
