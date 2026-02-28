import SwiftUI

public struct FloatCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    
    public init(padding: CGFloat = FloatSpacing.md, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(padding)
            .background(FloatColors.cardBackground)
            .cornerRadius(FloatSpacing.cardRadius)
    }
}
