//
//  ContentView.swift
//  FlowNavigationApp
//
//  Created by feng qiu on 2026/3/3.
//

import SwiftUI
import FlowNavigationCoordinator
import FlowNavigationTypes

struct HomeRootView: View {

    @EnvironmentObject var coordinator: FlowCoordinator

    var body: some View {

        VStack(spacing: 20) {

            Text("Home Root")
                .font(.largeTitle)

            Button("Push Profile") {
                coordinator.perform(.present(.profile, .sheet(allowsDismiss: false)))
            }

            Button("Present Settings") {
                coordinator.perform(.present(.settings))
            }

            Button("Push Test Detail") {
                coordinator.navigate(to: .testDetail)
            }

            Divider()

            Button("DeepLink → Profile") {

                Task {
                    let url = URL(string: "myapp://app/profile?id=888")!
                    await coordinator.navigate(to: url)
                }
            }

            Button("DeepLink → Detail") {

                Task {
                    let url = URL(string: "myapp://app/detail?title=HelloDeepLink")!
                    await coordinator.navigate(to: url)
                }
            }
        }
        .padding()
    }
}
