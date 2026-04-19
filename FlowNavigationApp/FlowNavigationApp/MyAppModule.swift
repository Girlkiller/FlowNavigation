//
//  MyAppModule.swift
//  FlowNavigationApp
//
//  Created by feng qiu on 2026/3/10.
//

import SwiftUI
import Foundation
import FlowNavigationCore
import FlowNavigationTypes
import FlowNavigationEnvironment

struct MyAppModule: @preconcurrency RouteModule {

    static let moduleID = "MyAppModule"

    @MainActor
    static func register(into registry: RouteRegistry) {

        let customNavBar = NavigationBarConfig(
            customBar: AnyView(
                DemoNavBarView()
            ),
            customBarHeight: 88
        )
        registry.register(
            RouteDescriptor(id: .home, navBar: customNavBar) { _ in
                AnyView(HomeRootView())
            }
        )
        registry.register(RouteDescriptor(id: .createPost, navBar: NavigationBarConfig(
            title: "弹窗",
            hidesBackButton: true,
            leadingItems: [
                NavBarItem(
                    view: AnyView(
                        Button {
                            NavigationEnvironment.shared.perform(
                                .dismissAndPresent(
                                    dismissID: .createPost,
                                    presentID: .profile,
                                    style: .fullScreen(transparent: false)
                                )
                            )
                        } label: {
                            Image(systemName: "xmark")
                                .tint(.black)
                        }
                    )
                )
            ]
        )) { context in
            AnyView(
                ZStack {
                    Color.black
                        .opacity(0.4)
                        .ignoresSafeArea()

                    Text("Create Post Page: " + "\(String(describing: registry.context.resolve(AppConfig.self)))")
                        .font(.title)
                        .foregroundColor(.white)
                }
            )
        })

        registry.register(
            RouteDescriptor(id: .profile) { context in

                let params = registry.parameters(for: .profile)
                let userID = params.get("id") ?? "unknown"

                return AnyView(
                    ProfileView(userID: userID)
                )
            }
        )
    }
}

private struct Family: Identifiable {
    let id: String
    let name: String
    let isDefault: Bool
}


struct DemoNavBarView: View {

    // ✅ 写死数据（完全独立）
    private let families: [Family] = [
        .init(id: "1", name: "张三一家", isDefault: true),
        .init(id: "2", name: "父母家庭", isDefault: false),
        .init(id: "3", name: "孩子家庭", isDefault: false)
    ]

    @State private var currentId: String = "1"

    var body: some View {

        VStack(spacing: 0) {

            // ✅ 顶部安全区
            Spacer()
                .frame(height: topInset)

            HStack(spacing: 8) {

                // 👇 家庭切换
                Menu {
                    ForEach(families) { family in
                        Button {
                            currentId = family.id
                        } label: {
                            familyRow(family: family)
                        }
                    }

                    Divider()

                    Button {
                    } label: {
                        Label("创建家庭", systemImage: "plus")
                    }

                    Button {
                    } label: {
                        Label("加入家庭", systemImage: "person.badge.plus")
                    }

                } label: {
                    HStack(spacing: 6) {
                        Text(currentFamily.name)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.primary)

                        Image(systemName: "chevron.down")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // 👇 右侧头像
                Button {
                    print("avatar tapped")
                } label: {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
        }
        .background(.ultraThinMaterial) // ✅ 更像系统
        .overlay(alignment: .bottom) {
            Divider() // ✅ 分割线
        }
    }
}

private extension DemoNavBarView {

    func familyRow(family: Family) -> some View {
        HStack(spacing: 8) {

            // 默认家庭
            if family.isDefault {
                Image(systemName: "house.fill")
                    .foregroundColor(.orange)
            }

            Text(family.name)

            Spacer()

            // 当前选中
            if family.id == currentId {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
    }

    var currentFamily: Family {
        families.first(where: { $0.id == currentId }) ?? families[0]
    }
}

private extension DemoNavBarView {

    var topInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?
            .safeAreaInsets.top ?? 44
    }
}
