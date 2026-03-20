//
//  MeView.swift
//  FlowNavigationApp
//
//  Created by feng qiu on 2026/3/20.
//

import Foundation
import SwiftUI

struct MeView: View {

    let userID: String

    var body: some View {

        ZStack {
            VStack(spacing: 20) {

                Text("Me Page")
                    .font(.largeTitle)

                Text("UserID: \(userID)")
            }
        }
    }
}
