//
//  File.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/15.
//

import Foundation

public enum PresentStyle: Codable, Equatable {
    case sheet(
        allowsDismiss: Bool = true
    )

    case fullScreen
}

extension PresentStyle {

    public var allowsDismiss: Bool {

        switch self {
        case .sheet(let allowsDismiss):
            return allowsDismiss

        case .fullScreen:
            return false
        }
    }
}
