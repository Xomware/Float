import SwiftUI

struct RedemptionHistoryView: View {
    @StateObject private var viewModel = RedemptionViewModel()
    @State private var userId: UUID = UUID()
    
    var body: some View {
        NavigationStack {
            ZStack {
                FloatColors.background.ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .tint(FloatColors.primary)
                } else if viewModel.redemptions.isEmpty {
                    VStack(spacing: FloatSpacing.lg) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 48))
                            .foregroundStyle(FloatColors.primary)
                        
                        Text("No Redemptions Yet")
                            .font(FloatFont.headline())
                            .foregroundStyle(FloatColors.textPrimary)
                        
                        Text("Your redeemed deals will appear here")
                            .font(FloatFont.body())
                            .foregroundStyle(FloatColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: FloatSpacing.md) {
                            ForEach(viewModel.redemptions) { redemption in
                                RedemptionHistoryCard(redemption: redemption)
                            }
                        }
                        .padding(FloatSpacing.md)
                    }
                }
            }
            .navigationTitle("Redemption History")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadRedemptionHistory(userId: userId)
            }
            .refreshable {
                await viewModel.loadRedemptionHistory(userId: userId)
            }
        }
    }
}

struct RedemptionHistoryCard: View {
    let redemption: Redemption
    
    var statusColor: Color {
        switch redemption.redeemedAt {
        case .some:
            return FloatColors.success
        default:
            return FloatColors.warning
        }
    }
    
    var statusIcon: String {
        redemption.redeemedAt != nil ? "checkmark.circle.fill" : "hourglass"
    }
    
    var statusText: String {
        if let redeemedAt = redemption.redeemedAt {
            return "Redeemed " + redeemedAt.formatted(date: .abbreviated, time: .shortened)
        }
        return "Pending Redemption"
    }
    
    var body: some View {
        FloatCard {
            VStack(alignment: .leading, spacing: FloatSpacing.md) {
                HStack(alignment: .top, spacing: FloatSpacing.md) {
                    VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                        Text(redemption.deal?.title ?? "Unknown Deal")
                            .font(FloatFont.headline())
                            .foregroundStyle(FloatColors.textPrimary)
                        
                        if let description = redemption.deal?.description {
                            Text(description)
                                .font(FloatFont.callout())
                                .foregroundStyle(FloatColors.textSecondary)
                                .lineLimit(2)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: statusIcon)
                        .font(.system(size: 20))
                        .foregroundStyle(statusColor)
                }
                
                Divider()
                    .background(FloatColors.textSecondary.opacity(0.2))
                
                HStack(spacing: FloatSpacing.lg) {
                    VStack(alignment: .leading, spacing: FloatSpacing.xs) {
                        Text("Status")
                            .font(FloatFont.caption())
                            .foregroundStyle(FloatColors.textSecondary)
                        
                        Text(statusText)
                            .font(FloatFont.callout())
                            .foregroundStyle(FloatColors.textPrimary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: FloatSpacing.xs) {
                        Text("Code")
                            .font(FloatFont.caption())
                            .foregroundStyle(FloatColors.textSecondary)
                        
                        Text(redemption.qrToken.prefix(8).uppercased())
                            .font(FloatFont.caption(.monospaced()))
                            .foregroundStyle(FloatColors.primary)
                    }
                }
            }
        }
    }
}

// Monospaced caption font helper
extension Font {
    static func caption(_ weight: Font.Weight = .regular) -> Font {
        .system(.caption, design: .monospaced, weight: weight)
    }
}

#Preview {
    RedemptionHistoryView()
        .environment(\.colorScheme, .dark)
}
