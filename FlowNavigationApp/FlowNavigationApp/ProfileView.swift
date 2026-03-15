//
//  ProfileView.swift
//  FlowNavigationApp
//
//  Created by feng qiu on 2026/3/10.
//

import SwiftUI

struct ProfileView: View {

    let userID: String

    var body: some View {

        ZStack {
            VStack(spacing: 20) {

                Text("Profile Page")
                    .font(.largeTitle)

                Text("UserID: \(userID)")
            }
        }
    }
}
