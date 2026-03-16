//
//  File.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/15.
//

import Foundation

public protocol RouteParameterConvertible {
    static func convert(from value: Any?) -> Self?
}

public struct RouteParameters {

    private let values: [String: Any]

    public init(values: [String: Any] = [:]) {
        self.values = values
    }

    public func value<T>(_ key: String) -> T? {
        values[key] as? T
    }

    public func get<T: RouteParameterConvertible>(_ key: String) -> T? {
        T.convert(from: values[key])
    }
}

extension String: RouteParameterConvertible {

    public static func convert(from value: Any?) -> String? {
        if let v = value as? String { return v }
        if let v = value { return String(describing: v) }
        return nil
    }
}

extension Int: RouteParameterConvertible {

    public static func convert(from value: Any?) -> Int? {

        if let v = value as? Int { return v }

        if let str = value as? String {
            return Int(str)
        }

        return nil
    }
}

extension Bool: RouteParameterConvertible {

    public static func convert(from value: Any?) -> Bool? {

        if let v = value as? Bool { return v }

        if let str = value as? String {
            return ["true","1","yes"].contains(str.lowercased())
        }

        return nil
    }
}

extension Double: RouteParameterConvertible {

    public static func convert(from value: Any?) -> Double? {

        if let v = value as? Double { return v }

        if let str = value as? String {
            return Double(str)
        }

        return nil
    }
}

extension URL: RouteParameterConvertible {

    public static func convert(from value: Any?) -> URL? {

        if let v = value as? URL { return v }

        if let str = value as? String {
            return URL(string: str)
        }

        return nil
    }
}

extension UUID: RouteParameterConvertible {

    public static func convert(from value: Any?) -> UUID? {

        if let v = value as? UUID { return v }

        if let str = value as? String {
            return UUID(uuidString: str)
        }

        return nil
    }
}

extension RawRepresentable where RawValue == String {

    static func convert(from value: Any?) -> Self? {

        guard let str = value as? String else { return nil }

        return Self(rawValue: str)
    }
}
