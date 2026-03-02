// FloatButton.swift
// Float

import SwiftUI

public struct FloatButton: View {
    let title: String
    let icon: String?
    let style: Style
    let isLoading: Bool
    let action: () -> Void
    
    public enum Style { case primary, secondary, ghost, destructive }
    
    public init(_ title: String, icon: String? = nil, style: Style = .primary, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title; self.icon = icon; self.style = style; self.isLoading = isLoading; self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: FloatSpacing.sm) {
                if isLoading {
                    ProgressView().tint(foregroundColor)
                } else {
                    if let icon { Image(systemName: icon) }
                    Text(title).font(FloatFont.headline())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .cornerRadius(FloatSpacing.buttonRadius)
            .overlay(RoundedRectangle(cornerRadius: FloatSpacing.buttonRadius).stroke(borderColor, lineWidth: style == .ghost ? 1.5 : 0))
        }
        .disabled(isLoading)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return FloatColors.primary
        case .secondary: return FloatColors.cardBackground
        case .ghost: return .clear
        case .destructive: return FloatColors.error
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive: return .white
        case .secondary: return FloatColors.textPrimary
        case .ghost: return FloatColors.primary
        }
    }
    
    private var borderColor: Color { style == .ghost ? FloatColors.primary : .clear }
}
