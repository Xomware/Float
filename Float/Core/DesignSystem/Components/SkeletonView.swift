// SkeletonView.swift
// Float

import SwiftUI

// MARK: - Shimmer Animation
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .clear, location: max(0, phase - 0.3)),
                        .init(color: Color.white.opacity(0.18), location: phase),
                        .init(color: .clear, location: min(1, phase + 0.3))
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .blendMode(.plusLighter)
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 1.4)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1.3
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Skeleton shape primitive
struct SkeletonShape: View {
    let width: CGFloat?
    let height: CGFloat
    var cornerRadius: CGFloat = FloatSpacing.xs

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(FloatColors.cardBackground.opacity(0.9))
            .frame(width: width, height: height)
            .shimmer()
    }
}

// MARK: - Deal Card Skeleton
public struct DealCardSkeletonView: View {
    public init() {}

    public var body: some View {
        FloatCard {
            VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                // Header row
                HStack(alignment: .top, spacing: FloatSpacing.sm) {
                    VStack(alignment: .leading, spacing: FloatSpacing.xs) {
                        SkeletonShape(width: 100, height: 12)
                        SkeletonShape(width: 180, height: 18, cornerRadius: 4)
                    }
                    Spacer()
                    SkeletonShape(width: 60, height: 12)
                }

                // Discount / timer row
                HStack(spacing: FloatSpacing.md) {
                    SkeletonShape(width: 80, height: 28, cornerRadius: 8)
                    Spacer()
                    SkeletonShape(width: 70, height: 14)
                }

                // Category icon row
                HStack(spacing: FloatSpacing.sm) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(FloatColors.cardBackground.opacity(0.9))
                        .frame(width: 40, height: 40)
                        .shimmer()
                    VStack(alignment: .leading, spacing: 4) {
                        SkeletonShape(width: 50, height: 10)
                        SkeletonShape(width: 130, height: 10)
                    }
                    Spacer()
                }
            }
        }
        .accessibilityLabel("Loading deal")
        .accessibilityElement(children: .ignore)
    }
}

// MARK: - Venue Row Skeleton
public struct VenueRowSkeletonView: View {
    public init() {}

    public var body: some View {
        HStack(spacing: FloatSpacing.md) {
            // Venue image placeholder
            RoundedRectangle(cornerRadius: 10)
                .fill(FloatColors.cardBackground.opacity(0.9))
                .frame(width: 60, height: 60)
                .shimmer()

            VStack(alignment: .leading, spacing: FloatSpacing.xs) {
                SkeletonShape(width: 140, height: 16, cornerRadius: 4)
                SkeletonShape(width: 100, height: 12)
                SkeletonShape(width: 60, height: 12)
            }

            Spacer()
        }
        .padding(.horizontal, FloatSpacing.md)
        .accessibilityLabel("Loading venue")
        .accessibilityElement(children: .ignore)
    }
}

// MARK: - Deal List Skeleton (full list)
public struct DealListSkeletonView: View {
    var count: Int = 4
    public init(count: Int = 4) { self.count = count }

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: FloatSpacing.sm) {
                ForEach(0..<count, id: \.self) { _ in
                    DealCardSkeletonView()
                }
            }
            .padding(.horizontal, FloatSpacing.md)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Venue List Skeleton
public struct VenueListSkeletonView: View {
    var count: Int = 5
    public init(count: Int = 5) { self.count = count }

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: FloatSpacing.sm) {
                ForEach(0..<count, id: \.self) { _ in
                    VenueRowSkeletonView()
                    Divider().background(FloatColors.textSecondary.opacity(0.2))
                }
            }
            .padding(.vertical, FloatSpacing.sm)
        }
        .allowsHitTesting(false)
    }
}
