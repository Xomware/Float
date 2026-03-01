import SwiftUI

struct RedemptionView: View {
    let deal: Deal
    @StateObject private var viewModel = RedemptionViewModel()
    @State private var userId: UUID = UUID()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                FloatColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: FloatSpacing.lg) {
                        // Deal Summary
                        VStack(alignment: .leading, spacing: FloatSpacing.md) {
                            Text(deal.title)
                                .font(FloatFont.title2())
                                .foregroundStyle(FloatColors.textPrimary)
                            
                            if let description = deal.description {
                                Text(description)
                                    .font(FloatFont.body())
                                    .foregroundStyle(FloatColors.textSecondary)
                                    .lineLimit(3)
                            }
                            
                            HStack(spacing: FloatSpacing.md) {
                                FloatBadge(deal.category.uppercased())
                                FloatBadge(deal.discountType.uppercased(), color: FloatColors.secondary)
                                Spacer()
                            }
                        }
                        .padding(FloatSpacing.md)
                        .background(FloatColors.cardBackground)
                        .cornerRadius(FloatSpacing.cardRadius)
                        
                        // QR Code Display
                        if let qrCode = viewModel.qrCode {
                            VStack(spacing: FloatSpacing.md) {
                                Text("Show to Staff")
                                    .font(FloatFont.headline())
                                    .foregroundStyle(FloatColors.textPrimary)
                                
                                Image(uiImage: qrCode)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 300, maxHeight: 300)
                                    .padding(FloatSpacing.lg)
                                    .background(FloatColors.cardBackground)
                                    .cornerRadius(FloatSpacing.cardRadius)
                                
                                VStack(spacing: FloatSpacing.sm) {
                                    Text("Redemption Code")
                                        .font(FloatFont.caption())
                                        .foregroundStyle(FloatColors.textSecondary)
                                    
                                    Text(viewModel.redemptionToken)
                                        .font(FloatFont.caption2(.monospaced()))
                                        .foregroundStyle(FloatColors.textPrimary)
                                        .lineLimit(1)
                                }
                                .padding(FloatSpacing.md)
                                .background(FloatColors.cardBackground)
                                .cornerRadius(FloatSpacing.cardRadius)
                                
                                Text("Scan this code or show your screen to the bartender to redeem your deal.")
                                    .font(FloatFont.body())
                                    .foregroundStyle(FloatColors.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(FloatSpacing.md)
                        } else {
                            ProgressView()
                                .tint(FloatColors.primary)
                                .padding(FloatSpacing.xxl)
                        }
                        
                        // Instructions
                        VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                            Label("Valid until today", systemImage: "calendar")
                                .font(FloatFont.callout())
                                .foregroundStyle(FloatColors.textSecondary)
                            
                            Label("One redemption per person", systemImage: "person.fill")
                                .font(FloatFont.callout())
                                .foregroundStyle(FloatColors.textSecondary)
                            
                            Label("Keep your phone charged", systemImage: "battery.50")
                                .font(FloatFont.callout())
                                .foregroundStyle(FloatColors.textSecondary)
                        }
                        .padding(FloatSpacing.md)
                        .background(FloatColors.cardBackground)
                        .cornerRadius(FloatSpacing.cardRadius)
                        
                        // Action Buttons
                        VStack(spacing: FloatSpacing.md) {
                            FloatButton("Share Redemption", icon: "square.and.arrow.up", style: .primary) {
                                shareRedemption()
                            }
                            
                            FloatButton("Close", style: .secondary) {
                                dismiss()
                            }
                        }
                        .padding(FloatSpacing.md)
                    }
                    .padding(FloatSpacing.md)
                }
                
                // Success Animation Overlay
                if viewModel.successAnimation {
                    ZStack {
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                        
                        VStack(spacing: FloatSpacing.lg) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 64))
                                .foregroundStyle(FloatColors.success)
                                .scaleEffect(viewModel.successAnimation ? 1.0 : 0.3)
                            
                            Text("Redemption Ready!")
                                .font(FloatFont.title())
                                .foregroundStyle(.white)
                        }
                        .padding(FloatSpacing.xxl)
                        .background(FloatColors.cardBackground)
                        .cornerRadius(FloatSpacing.cardRadius)
                        .onAppear {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                // Animation handled by property change
                            }
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .navigationTitle("Redeem Deal")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    await viewModel.redeemDeal(deal, userId: userId)
                }
            }
        }
    }
    
    private func shareRedemption() {
        let message = "I'm using Float to redeem '\(deal.title)' - get Float for awesome deals!"
        let activityVC = UIActivityViewController(
            activityItems: [message],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
}

// Helper for monospaced font
extension Font {
    static func caption2(_ weight: Font.Weight = .regular) -> Font {
        .system(.caption2, design: .monospaced, weight: weight)
    }
}

#Preview {
    let dealPreview = Deal(
        id: UUID(),
        title: "2-for-1 Margaritas",
        description: "Buy one margarita, get one free tonight only",
        category: "drink",
        venueId: UUID(),
        venueName: "El Paso Bar",
        expiresAt: Date().addingTimeInterval(3600),
        discountType: "bogo",
        discountValue: nil
    )
    
    RedemptionView(deal: dealPreview)
        .environment(\.colorScheme, .dark)
}
