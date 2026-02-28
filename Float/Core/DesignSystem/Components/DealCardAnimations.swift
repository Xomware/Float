import SwiftUI

// MARK: - Animated Deal Card List Item
/// Wrap DealCardView with this to get slide-in + fade-in entrance animation.
public struct AnimatedDealCard<Content: View>: View {
    let index: Int
    let content: Content

    @State private var appeared = false

    public init(index: Int, @ViewBuilder content: () -> Content) {
        self.index = index
        self.content = content()
    }

    public var body: some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 24)
            .scaleEffect(appeared ? 1 : 0.97)
            .animation(
                .spring(response: 0.48, dampingFraction: 0.78)
                .delay(Double(index) * 0.06),
                value: appeared
            )
            .onAppear {
                appeared = true
            }
    }
}

// MARK: - Tap Feedback Modifier
/// Adds a subtle scale press animation to any view, matching the Float card aesthetic.
public struct CardPressEffect: ViewModifier {
    @GestureState private var isPressed = false

    public func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressed) { _, state, _ in state = true }
            )
    }
}

public extension View {
    func cardPressEffect() -> some View {
        modifier(CardPressEffect())
    }
}

// MARK: - Slide-in from bottom (sheet / panel entrance)
public struct SlideInModifier: ViewModifier {
    @State private var appeared = false
    let delay: Double

    public init(delay: Double = 0) { self.delay = delay }

    public func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 40)
            .animation(.spring(response: 0.52, dampingFraction: 0.76).delay(delay), value: appeared)
            .onAppear { appeared = true }
    }
}

public extension View {
    func slideIn(delay: Double = 0) -> some View {
        modifier(SlideInModifier(delay: delay))
    }
}

// MARK: - Fade Transition (for view replacement)
public extension AnyTransition {
    static var floatFade: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.96)),
            removal: .opacity
        )
    }

    static var floatSlideUp: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }
}

// MARK: - Bookmark Bounce Animation
public struct BookmarkBounceModifier: ViewModifier {
    let isBookmarked: Bool

    public func body(content: Content) -> some View {
        content
            .scaleEffect(isBookmarked ? 1.25 : 1.0)
            .animation(
                isBookmarked
                    ? .spring(response: 0.35, dampingFraction: 0.5)
                    : .spring(response: 0.3, dampingFraction: 0.65),
                value: isBookmarked
            )
    }
}

public extension View {
    func bookmarkBounce(isBookmarked: Bool) -> some View {
        modifier(BookmarkBounceModifier(isBookmarked: isBookmarked))
    }
}

// MARK: - Shimmer-less Loading Pulse (alternative to shimmer)
public struct PulseModifier: ViewModifier {
    @State private var pulsing = false

    public func body(content: Content) -> some View {
        content
            .opacity(pulsing ? 0.5 : 1.0)
            .animation(.easeInOut(duration: 0.85).repeatForever(autoreverses: true), value: pulsing)
            .onAppear { pulsing = true }
    }
}

public extension View {
    func loadingPulse() -> some View {
        modifier(PulseModifier())
    }
}
