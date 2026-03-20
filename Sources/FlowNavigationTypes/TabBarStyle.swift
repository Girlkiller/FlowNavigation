//
//  File.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/18.
//

import Foundation
import SwiftUI

public struct TabBarStyle {

    // MARK: - TabBar 基础样式
    public var height: CGFloat
    public var bottomSafeArea: CGFloat
    public var horizontalPadding: CGFloat
    public var topPadding: CGFloat
    public var bottomPadding: CGFloat
    public var itemSpacing: CGFloat

    public var iconFontSize: CGFloat
    public var iconSize: CGFloat
    public var selectedIconScale: CGFloat

    public var font: Font
    public var selectedFont: Font
    public var selectedColor: Color
    public var normalColor: Color

    public var backgroundColor: Color
    public var backgroundMaterial: Material?
    public var cornerRadius: CGFloat

    public enum WidthMode {
        case full
        case inset
    }
    public var widthMode: WidthMode

    // MARK: - 中间大按钮样式
    public var centerSize: CGFloat
    public var centerIconFontSize: CGFloat
    public var centerIconFontWeight: Font.Weight
    public var centerOffsetY: CGFloat
    public var centerBackgroundColor: Color
    public var centerForegroundColor: Color
    public var centerCornerRadius: CGFloat
    public var centerShadowRadius: CGFloat

    // MARK: - 红点样式
    public var badgeFontSize: CGFloat
    public var badgeSize: CGFloat
    public var badgeBackgroundColor: Color
    public var badgeTextColor: Color
    public var badgeOffset: CGSize

    // MARK: - 默认初始化方法
    public init(
        height: CGFloat = 60,
        bottomSafeArea: CGFloat = 0,
        horizontalPadding: CGFloat = 16,
        topPadding: CGFloat = 10,
        bottomPadding: CGFloat = 0,
        itemSpacing: CGFloat = 10,
        iconFontSize: CGFloat = 20,
        iconSize: CGFloat = 28,
        selectedIconScale: CGFloat = 1,
        font: Font = .system(size: 12),
        selectedFont: Font = .system(size: 12),
        selectedColor: Color = .blue,
        normalColor: Color = .gray,
        backgroundColor: Color = .clear,
        backgroundMaterial: Material? = .thinMaterial,
        cornerRadius: CGFloat = 0,
        widthMode: WidthMode = .full,
        centerSize: CGFloat = 64,
        centerIconFontSize: CGFloat = 16,
        centerIconFontWeight: Font.Weight = .semibold,
        centerOffsetY: CGFloat = -45,
        centerBackgroundColor: Color = .blue,
        centerForegroundColor: Color = .white,
        centerCornerRadius: CGFloat = 32,
        centerShadowRadius: CGFloat = 6,
        badgeFontSize: CGFloat = 10,
        badgeSize: CGFloat = 18,
        badgeBackgroundColor: Color = .red,
        badgeTextColor: Color = .white,
        badgeOffset: CGSize = CGSize(width: 10, height: -6)
    ) {
        self.height = height
        self.bottomSafeArea = bottomSafeArea
        self.horizontalPadding = horizontalPadding
        self.topPadding = topPadding
        self.bottomPadding = bottomPadding
        self.itemSpacing = itemSpacing
        self.iconFontSize = iconFontSize
        self.iconSize = iconSize
        self.selectedIconScale = selectedIconScale
        self.font = font
        self.selectedFont = selectedFont
        self.selectedColor = selectedColor
        self.normalColor = normalColor
        self.backgroundColor = backgroundColor
        self.backgroundMaterial = backgroundMaterial
        self.cornerRadius = cornerRadius
        self.widthMode = widthMode
        self.centerSize = centerSize
        self.centerIconFontSize = centerIconFontSize
        self.centerIconFontWeight = centerIconFontWeight
        self.centerOffsetY = centerOffsetY
        self.centerBackgroundColor = centerBackgroundColor
        self.centerForegroundColor = centerForegroundColor
        self.centerCornerRadius = centerCornerRadius
        self.centerShadowRadius = centerShadowRadius
        self.badgeFontSize = badgeFontSize
        self.badgeSize = badgeSize
        self.badgeBackgroundColor = badgeBackgroundColor
        self.badgeTextColor = badgeTextColor
        self.badgeOffset = badgeOffset
    }
}
