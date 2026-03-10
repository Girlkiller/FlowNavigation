//
//  TestDetailView.swift
//  FlowNavigationApp
//
//  Created by feng qiu on 2026/3/10.
//

import Foundation
import SwiftUI

struct TestDetailView: View {

    let title: String

    var body: some View {

        VStack(spacing: 20) {

            Text("Test Detail")
                .font(.largeTitle)

            Text(title)
        }
    }
}
