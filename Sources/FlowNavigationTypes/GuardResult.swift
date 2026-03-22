//
//  File.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/22.
//

import Foundation

public enum GuardResult {
    case allow
    case deny
    case redirect(NavigationRedirect)
}
