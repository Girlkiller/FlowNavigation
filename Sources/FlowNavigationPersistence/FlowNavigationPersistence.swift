//
//  FlowNavigationPersistence.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/3.
//

import FlowNavigationCore
import Foundation
import FlowNavigationTypes

public final class FlowPersistence {

    private let key = "flow.navigation.state"

    public func save(_ state: TabNavigationState) throws {
        let data = try JSONEncoder().encode(state)
        UserDefaults.standard.set(data, forKey: key)
    }

    public func restore() throws -> TabNavigationState? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try JSONDecoder().decode(TabNavigationState.self, from: data)
    }
}
