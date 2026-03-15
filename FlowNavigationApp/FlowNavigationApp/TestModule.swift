//
//  TestModule.swift
//  FlowNavigationApp
//
//  Created by feng qiu on 2026/3/10.
//

import SwiftUI
import FlowNavigationCore
import FlowNavigationTypes

struct TestModule: @preconcurrency RouteModule {

    static let moduleID = "TestModule"

    @MainActor
    static func register(into registry: RouteRegistry) {

        registry.register(
            RouteDescriptor(id: .testDetail) {

                let params = registry.parameters(for: .testDetail)
                let title = params["title"] ?? "Default Title"

                return AnyView(
                    TestDetailView(title: title)
                )
            }
        )
    }
}
