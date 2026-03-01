// FloatBadge.swift
// Float

import SwiftUI

public struct FloatBadge: View {
    let text: String
    let color: Color
    
    public init(_ text: String, color: Color = FloatColors.primary) {
        self.text = text; self.color = color
    }
    
    public var body: some View {
        Text(text)
            .font(FloatFont.caption2())
            .fontWeight(.semibold)
            .padding(.horizontal, FloatSpacing.sm)
            .padding(.vertical, 3)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .cornerRadius(FloatSpacing.badgeRadius)
    }
}
