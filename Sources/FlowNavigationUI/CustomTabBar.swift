//
//  File.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/18.
//

import Foundation
import FlowNavigationTypes
import SwiftUI

struct CustomTabBar: View {
    let tabs: [TabDescriptor]
    @Binding var selectedTab: String
    let centerTab: TabDescriptor?
    let hidden: Bool
    var centerButtonStyle: ((AnyView) -> AnyView)? = nil
    let style: TabBarStyle
    let onTabSelected: (String) -> Void
    let onCenterTap: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            // TabBar 背景 + 左右按钮
            tabBarContent

            // 中间大按钮悬浮在 TabBar 上方
            if let centerTab {
                centerButton(centerTab)
                    .zIndex(1) // 保证浮层覆盖
            }
        }
        .padding(style.widthMode == .inset ? style.horizontalPadding : 0)
        .frame(maxWidth: style.widthMode == .full ? .infinity : nil)
        .offset(y: hidden ? 120 : 0)
        .opacity(hidden ? 0 : 1)
        .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.85), value: hidden)
    }

    // MARK: - TabBar Content
    private var tabBarContent: some View {
        HStack(spacing: style.itemSpacing) {
            ForEach(tabs) { tab in
                if tab.style == .centerButton {
                    // ✅ 中间按钮占位，保证左右 Tab 间距
                    Color.clear
                        .frame(width: style.centerSize + 12)
                } else {
                    tabItem(tab)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle()) // 点击区域扩展
                }
            }
        }
        .padding(.top, style.topPadding)
        .frame(height: style.height)
        .padding(.bottom, style.bottomSafeArea + style.bottomPadding)
        .background(backgroundView)
        .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius))
    }

    // MARK: - Background
    @ViewBuilder
    private var backgroundView: some View {
        if let material = style.backgroundMaterial {
            Rectangle().fill(material)
        } else {
            Rectangle().fill(style.backgroundColor)
        }
    }

    // MARK: - Tab Item
    private func tabItem(_ tab: TabDescriptor) -> some View {
        Button {
            onTabSelected(tab.id)
        } label: {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    iconView(tab.icon)
                        .font(.system(size: style.iconFontSize))
                        .frame(width: style.iconSize, height: style.iconSize)
                        .scaleEffect(selectedTab == tab.id ? style.selectedIconScale : 1)
                    if let badge = tab.badge, badge > 0 {
                        badgeView(badge)
                    }
                }
                Text(tab.title)
                    .font(selectedTab == tab.id ? style.selectedFont : style.font)
            }
            .foregroundColor(selectedTab == tab.id ? style.selectedColor : style.normalColor)
        }
    }

    // MARK: - Badge
    private func badgeView(_ value: Int) -> some View {
        Text("\(value)")
            .font(.system(size: style.badgeFontSize))
            .frame(width: style.badgeSize, height: style.badgeSize)
            .background(style.badgeBackgroundColor)
            .foregroundColor(style.badgeTextColor)
            .clipShape(Circle())
            .offset(style.badgeOffset)
    }

    // MARK: - Center Button
    private func centerButton(_ tab: TabDescriptor) -> some View {
        Button(action: onCenterTap) {
            let icon = AnyView(iconView(tab.icon))
            (centerButtonStyle?(icon) ?? AnyView(defaultCenterStyle(tab.icon)))
        }
        .offset(y: style.centerOffsetY) // 控制凸起高度
    }

    private func defaultCenterStyle(_ icon: TabIcon) -> some View {
        ZStack {
            // 背景按钮
            RoundedRectangle(cornerRadius: style.centerCornerRadius)
                .fill(style.centerBackgroundColor)
                .frame(width: style.centerSize, height: style.centerSize)
                .shadow(radius: style.centerShadowRadius)

            // 图标
            switch icon {
            case .system(let name):
                Image(systemName: name)
                    .resizable() // SF Symbols 可用 resizable
                    .scaledToFit()
                    .frame(width: style.centerIconSize, height: style.centerIconSize)
                    .foregroundColor(style.centerForegroundColor)
            case .asset(let name):
                Image(name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: style.centerIconSize, height: style.centerIconSize)
                    .foregroundColor(style.centerForegroundColor)
            case .remote(let url):
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(width: style.centerIconSize, height: style.centerIconSize)
                        .foregroundColor(style.centerForegroundColor)
                } placeholder: {
                    ProgressView()
                }
            }
        }
    }

    // MARK: - Icon View
    @ViewBuilder
    private func iconView(_ icon: TabIcon) -> some View {
        switch icon {
        case .system(let name):
            Image(systemName: name)
                .renderingMode(.template)
        case .asset(let name):
            Image(name)
                .resizable()
                .scaledToFit()
        case .remote(let url):
            AsyncImage(url: url) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
        }
    }
}
