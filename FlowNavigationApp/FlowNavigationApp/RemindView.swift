//
//  RemindView.swift
//  FlowNavigationApp
//
//  Created by feng qiu on 2026/3/20.
//

import Foundation

import SwiftUI

struct RemindView: View {

    var id: String

    var body: some View {

        ZStack {
            VStack(spacing: 20) {

                Text("Remind Page")
                    .font(.largeTitle)

                Text("Remind: \(id)")
            }
        }
    }
}
