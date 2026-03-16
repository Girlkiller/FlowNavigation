//
//  RouteRegistry.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/3.
//

import Foundation
import SwiftUI
import Combine
import FlowNavigationTypes

@preconcurrency
public protocol RouteModule {
    static var moduleID: String { get }
    static func register(into registry: RouteRegistry)
}

@MainActor
public final class RouteRegistry: ObservableObject {
    private var descriptors: [RouteID: RouteDescriptor] = [:]
    private var modules: Set<String> = []

    public var context: RouteContext = .init()

    public init() {}

    public func registerModule<M: RouteModule>(_ module: M.Type) {
        guard !modules.contains(module.moduleID) else { return }
        module.register(into: self)
        modules.insert(module.moduleID)
    }

    public func register(_ descriptor: RouteDescriptor) {
        descriptors[descriptor.id] = descriptor
    }

    public func view(for id: RouteID) -> AnyView {
        guard let descriptor = descriptors[id] else {
            return AnyView(Text("Unregistered Route: \(id.rawValue)"))
        }

        if let view = descriptor.factory(context) as? AnyView {
            return view
        } else if let vc = descriptor.factory(context) as? UIViewController {
            return AnyView(UIViewControllerWrapper(vc: vc))
        } else {
            return AnyView(Text("Invalid factory for: \(id.rawValue)"))
        }
    }

    public func descriptor(for id: RouteID) -> RouteDescriptor? {
        return descriptors[id]
    }
}
