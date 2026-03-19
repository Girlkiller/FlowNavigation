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
        ZStack {
            tabBarContent
            if let centerTab { centerButton(centerTab) }
        }
        .padding(style.widthMode == .inset ? style.horizontalPadding : 0)
        .frame(maxWidth: style.widthMode == .full ? .infinity : nil)
        .offset(y: hidden ? 120 : 0)
        .opacity(hidden ? 0 : 1)
        .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.85), value: hidden)
    }

    private var tabBarContent: some View {
        HStack(spacing: style.itemSpacing) {
            ForEach(tabs) { tab in
                if tab.style == .centerButton { Spacer() }
                else { tabItem(tab).frame(maxWidth: .infinity) }
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 0)
        .frame(height: style.height)
        .background(backgroundView)
        .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius))
    }

    @ViewBuilder
    private var backgroundView: some View {
        if let material = style.backgroundMaterial {
            Rectangle().fill(material)
        } else {
            Rectangle().fill(style.backgroundColor)
        }
    }

    private func tabItem(_ tab: TabDescriptor) -> some View {
        Button {
            onTabSelected(tab.id)
        } label: {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    iconView(tab.icon)
                        .frame(width: style.iconSize, height: style.iconSize)
                        .scaleEffect(selectedTab == tab.id ? style.selectedIconScale : 1)
                    if let badge = tab.badge, badge > 0 { badgeView(badge) }
                }
                Text(tab.title).font(selectedTab == tab.id ? style.selectedFont : style.font)
            }
            .foregroundColor(selectedTab == tab.id ? style.selectedColor : style.normalColor)
        }
    }

    private func badgeView(_ value: Int) -> some View {
        Text("\(value)")
            .font(.system(size: style.badgeFontSize))
            .frame(width: style.badgeSize, height: style.badgeSize)
            .background(style.badgeBackgroundColor)
            .foregroundColor(style.badgeTextColor)
            .clipShape(Circle())
            .offset(style.badgeOffset)
    }

    private func centerButton(_ tab: TabDescriptor) -> some View {
        Button(action: onCenterTap) {
            let icon = AnyView(iconView(tab.icon))
            (centerButtonStyle?(icon) ?? defaultCenterStyle(icon))
        }
        .offset(y: style.centerOffsetY)
    }

    private func defaultCenterStyle(_ icon: AnyView) -> AnyView {
        AnyView(
            icon
                .frame(width: style.centerSize, height: style.centerSize)
                .background(style.centerBackgroundColor)
                .foregroundColor(style.centerForegroundColor)
                .clipShape(RoundedRectangle(cornerRadius: style.centerCornerRadius))
                .shadow(radius: style.centerShadowRadius)
        )
    }

    @ViewBuilder
    private func iconView(_ icon: TabIcon) -> some View {
        switch icon {
        case .system(let name): Image(systemName: name)
        case .asset(let name): Image(name).resizable().scaledToFit()
        case .remote(let url):
            AsyncImage(url: url) { image in image.resizable().scaledToFit() } placeholder: { ProgressView() }
        }
    }
}
