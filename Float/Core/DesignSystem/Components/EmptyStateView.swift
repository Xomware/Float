import SwiftUI

// MARK: - Empty State Configuration
public struct EmptyStateConfig {
    public let systemImage: String
    public let title: String
    public let subtitle: String
    public var actionTitle: String?
    public var action: (() -> Void)?
    public var imageColor: Color

    public init(
        systemImage: String,
        title: String,
        subtitle: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        imageColor: Color = FloatColors.primary
    ) {
        self.systemImage = systemImage
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
        self.imageColor = imageColor
    }
}

// MARK: - Empty State View
public struct EmptyStateView: View {
    let config: EmptyStateConfig
    @State private var appeared = false

    public init(_ config: EmptyStateConfig) {
        self.config = config
    }

    public var body: some View {
        VStack(spacing: FloatSpacing.lg) {
            Spacer()

            // SF Symbol illustration
            ZStack {
                Circle()
                    .fill(config.imageColor.opacity(0.12))
                    .frame(width: 100, height: 100)
                Image(systemName: config.systemImage)
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(config.imageColor)
                    .symbolRenderingMode(.hierarchical)
            }
            .scaleEffect(appeared ? 1 : 0.6)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.55, dampingFraction: 0.7).delay(0.05), value: appeared)

            // Text content
            VStack(spacing: FloatSpacing.xs) {
                Text(config.title)
                    .font(FloatFont.headline())
                    .foregroundStyle(FloatColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(config.subtitle)
                    .font(FloatFont.body())
                    .foregroundStyle(FloatColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, FloatSpacing.xl)
            }
            .offset(y: appeared ? 0 : 12)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.55, dampingFraction: 0.75).delay(0.1), value: appeared)

            // Optional action button
            if let title = config.actionTitle, let action = config.action {
                Button(action: action) {
                    Text(title)
                        .font(FloatFont.callout(.semibold))
                        .foregroundStyle(FloatColors.background)
                        .padding(.horizontal, FloatSpacing.xl)
                        .padding(.vertical, FloatSpacing.sm)
                        .background(FloatColors.primary)
                        .clipShape(Capsule())
                }
                .offset(y: appeared ? 0 : 12)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.55, dampingFraction: 0.75).delay(0.17), value: appeared)
                .accessibilityLabel(title)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .onAppear { appeared = true }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(config.title). \(config.subtitle)")
    }
}

// MARK: - Preset Empty States
public extension EmptyStateConfig {
    static func noDealsNearby(action: @escaping () -> Void) -> EmptyStateConfig {
        EmptyStateConfig(
            systemImage: "mappin.slash",
            title: "No Deals Nearby",
            subtitle: "There are no active deals in your area right now. Try expanding your search radius.",
            actionTitle: "Expand Search",
            action: action,
            imageColor: FloatColors.accent
        )
    }

    static func noSearchResults(query: String, action: @escaping () -> Void) -> EmptyStateConfig {
        EmptyStateConfig(
            systemImage: "magnifyingglass",
            title: "No Results for "\(query)"",
            subtitle: "Try different keywords or browse by category.",
            actionTitle: "Clear Search",
            action: action,
            imageColor: FloatColors.primary
        )
    }

    static func noBookmarks(action: @escaping () -> Void) -> EmptyStateConfig {
        EmptyStateConfig(
            systemImage: "bookmark.slash",
            title: "No Saved Deals",
            subtitle: "Tap the bookmark icon on any deal to save it here for later.",
            actionTitle: "Explore Deals",
            action: action,
            imageColor: FloatColors.primary
        )
    }

    static func noVenues(action: @escaping () -> Void) -> EmptyStateConfig {
        EmptyStateConfig(
            systemImage: "storefront.slash",
            title: "No Venues Found",
            subtitle: "No venues are currently participating in this area. Check back soon!",
            actionTitle: "Refresh",
            action: action,
            imageColor: FloatColors.drinkColor
        )
    }

    static let offlineEmpty = EmptyStateConfig(
        systemImage: "wifi.slash",
        title: "You're Offline",
        subtitle: "Float needs a connection to show deals. Check your internet and try again.",
        imageColor: FloatColors.textSecondary
    )
}
