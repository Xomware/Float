import SwiftUI

extension View {
    func floatCardStyle() -> some View {
        self
            .padding(FloatSpacing.md)
            .background(FloatColors.cardBackground)
            .cornerRadius(FloatSpacing.cardRadius)
    }
    
    func floatScreenBackground() -> some View {
        self.background(FloatColors.background.ignoresSafeArea())
    }
    
    func shimmer(active: Bool) -> some View {
        self.redacted(reason: active ? .placeholder : [])
    }
}
