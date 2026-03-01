import SwiftUI

// MARK: - ShareDealView

/// Preview card shown before sharing, with a prominent share button.
struct ShareDealView: View {
    let deal: Deal
    @Environment(\.dismiss) var dismiss
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: FloatSpacing.xl) {
                Spacer()

                // Deal preview card
                dealPreviewCard
                    .padding(.horizontal, FloatSpacing.lg)

                // Share actions
                VStack(spacing: FloatSpacing.md) {
                    FloatButton("Share This Deal", icon: "square.and.arrow.up", style: .primary) {
                        showShareSheet = true
                        AnalyticsService.shared.track("deal_shared", properties: [
                            "deal_id": deal.id.uuidString,
                            "method": "share_deal_view"
                        ])
                    }

                    Button {
                        UIPasteboard.general.string = SocialSharingService.shared.shareText(for: deal)
                        dismiss()
                    } label: {
                        HStack(spacing: FloatSpacing.sm) {
                            Image(systemName: "doc.on.doc")
                            Text("Copy Link")
                        }
                        .font(FloatFont.body(.semibold))
                        .foregroundStyle(FloatColors.adaptiveTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(FloatColors.adaptiveCardBackground)
                        .cornerRadius(14)
                    }
                    .accessibilityLabel("Copy deal link to clipboard")
                }
                .padding(.horizontal, FloatSpacing.lg)

                Spacer()
            }
            .background(FloatColors.adaptiveBackground.ignoresSafeArea())
            .navigationTitle("Share Deal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(FloatColors.primary)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [SocialSharingService.shared.shareText(for: deal)])
                .presentationDetents([.medium])
        }
    }

    // MARK: Deal Preview Card

    private var dealPreviewCard: some View {
        VStack(spacing: FloatSpacing.md) {
            // App branding
            HStack {
                Text("🌊 float")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(FloatColors.primary)
                Spacer()
                Text("ACTIVE DEAL")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(FloatColors.success)
                    .cornerRadius(6)
            }

            Divider().background(FloatColors.adaptiveSeparator)

            // Discount hero
            Text(deal.discountDisplay)
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundStyle(deal.categoryColor)
                .multilineTextAlignment(.center)
                .accessibilityLabel("Discount: \(deal.discountDisplay)")

            // Title
            Text(deal.title)
                .font(FloatFont.title())
                .foregroundStyle(FloatColors.adaptiveTextPrimary)
                .multilineTextAlignment(.center)

            // Venue
            HStack(spacing: FloatSpacing.xs) {
                Image(systemName: "location.fill")
                    .font(.caption)
                    .foregroundStyle(FloatColors.adaptiveTextSecondary)
                Text(deal.venueName ?? "Unknown Venue")
                    .font(FloatFont.callout())
                    .foregroundStyle(FloatColors.adaptiveTextSecondary)
            }

            // Expiry
            if let expiresAt = deal.expiresAt {
                HStack(spacing: FloatSpacing.xs) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundStyle(FloatColors.warning)
                    Text("Expires ")
                        .font(FloatFont.caption()) +
                    Text(expiresAt, style: .relative)
                        .font(FloatFont.caption(.semibold))
                }
                .foregroundStyle(FloatColors.warning)
            }
        }
        .padding(FloatSpacing.lg)
        .background(FloatColors.adaptiveCardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Share Button Modifier

extension View {
    /// Adds a share button overlay to any view that presents ShareDealView.
    func shareButton(deal: Deal) -> some View {
        self.modifier(ShareButtonModifier(deal: deal))
    }
}

struct ShareButtonModifier: ViewModifier {
    let deal: Deal
    @State private var showShareView = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showShareView = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(FloatColors.adaptiveTextPrimary)
                    }
                    .accessibilityLabel("Share deal")
                }
            }
            .sheet(isPresented: $showShareView) {
                ShareDealView(deal: deal)
            }
    }
}

#Preview {
    ShareDealView(deal: Deal(
        id: UUID(),
        title: "2-for-1 Cocktails",
        description: "Buy one get one free on all cocktails tonight",
        category: "drink",
        venueId: UUID(),
        venueName: "The Daily Brew",
        expiresAt: Date().addingTimeInterval(3600),
        startsAt: Date(),
        discountType: "bogo",
        discountValue: nil,
        terms: "Valid at bar only.",
        distance: 300,
        distanceFromUser: 300
    ))
    .preferredColorScheme(.dark)
}
