import SwiftUI
import Charts

// MARK: - Analytics Data Models

struct RedemptionStats {
    var totalRedemptions: Int
    var totalSaved: Double
    var thisMonthRedemptions: Int
    var thisMonthSaved: Double
    var streakDays: Int
    var topCategory: String
    var weeklyData: [WeeklyDataPoint]
    var categoryBreakdown: [CategoryDataPoint]
    var topVenues: [VenueDataPoint]

    struct WeeklyDataPoint: Identifiable {
        let id = UUID()
        let week: String
        let count: Int
        let savings: Double
    }

    struct CategoryDataPoint: Identifiable {
        let id = UUID()
        let category: String
        let count: Int
        let color: Color
    }

    struct VenueDataPoint: Identifiable {
        let id = UUID()
        let venueName: String
        let visits: Int
        let savings: Double
    }

    static var mock: RedemptionStats {
        RedemptionStats(
            totalRedemptions: 34,
            totalSaved: 187.50,
            thisMonthRedemptions: 8,
            thisMonthSaved: 42.75,
            streakDays: 5,
            topCategory: "Drinks",
            weeklyData: [
                .init(week: "Jan 27", count: 2, savings: 18.50),
                .init(week: "Feb 3", count: 4, savings: 31.00),
                .init(week: "Feb 10", count: 1, savings: 8.50),
                .init(week: "Feb 17", count: 5, savings: 42.75),
                .init(week: "Feb 24", count: 3, savings: 25.00),
            ],
            categoryBreakdown: [
                .init(category: "Drinks", count: 18, color: FloatColors.drinkColor),
                .init(category: "Food", count: 10, color: FloatColors.foodColor),
                .init(category: "Combo", count: 4, color: FloatColors.comboColor),
                .init(category: "Flash", count: 2, color: FloatColors.eventColor),
            ],
            topVenues: [
                .init(venueName: "The Daily Brew", visits: 8, savings: 54.50),
                .init(venueName: "Happy Hour Haven", visits: 6, savings: 38.00),
                .init(venueName: "Cocktail Corner", visits: 5, savings: 29.75),
            ]
        )
    }
}

// MARK: - AnalyticsDashboardViewModel

@MainActor
final class AnalyticsDashboardViewModel: ObservableObject {
    @Published var stats: RedemptionStats?
    @Published var isLoading = false
    @Published var dateRange: DateRange = .thisMonth

    enum DateRange: String, CaseIterable {
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case allTime = "All Time"
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        try? await Task.sleep(nanoseconds: 600_000_000) // simulate fetch
        stats = RedemptionStats.mock
        AnalyticsService.shared.screen("AnalyticsDashboard", properties: ["range": dateRange.rawValue])
    }
}

// MARK: - AnalyticsDashboardView

struct AnalyticsDashboardView: View {
    @StateObject private var viewModel = AnalyticsDashboardViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading stats…")
                        .tint(FloatColors.primary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let stats = viewModel.stats {
                    dashboardContent(stats)
                } else {
                    EmptyView()
                }
            }
            .background(FloatColors.adaptiveBackground.ignoresSafeArea())
            .navigationTitle("My Stats")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Picker("Range", selection: $viewModel.dateRange) {
                        ForEach(AnalyticsDashboardViewModel.DateRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(FloatColors.primary)
                }
            }
        }
        .task { await viewModel.load() }
        .onChange(of: viewModel.dateRange) { _ in
            Task { await viewModel.load() }
        }
    }

    // MARK: Dashboard Content

    @ViewBuilder
    private func dashboardContent(_ stats: RedemptionStats) -> some View {
        ScrollView {
            VStack(spacing: FloatSpacing.lg) {
                // Hero stats
                heroStats(stats)
                    .padding(.horizontal, FloatSpacing.md)

                // Streak
                streakCard(stats)
                    .padding(.horizontal, FloatSpacing.md)

                // Weekly activity chart
                weeklyChart(stats)
                    .padding(.horizontal, FloatSpacing.md)

                // Category breakdown
                categoryBreakdown(stats)
                    .padding(.horizontal, FloatSpacing.md)

                // Top venues
                topVenues(stats)
                    .padding(.horizontal, FloatSpacing.md)

                Spacer().frame(height: FloatSpacing.xl)
            }
            .padding(.top, FloatSpacing.md)
        }
    }

    // MARK: Hero Stats

    @ViewBuilder
    private func heroStats(_ stats: RedemptionStats) -> some View {
        VStack(spacing: FloatSpacing.sm) {
            HStack(spacing: FloatSpacing.sm) {
                analyticsStatCard(
                    value: "\(stats.totalRedemptions)",
                    label: "Total Redeemed",
                    icon: "tag.fill",
                    color: FloatColors.primary
                )
                analyticsStatCard(
                    value: "$\(String(format: "%.0f", stats.totalSaved))",
                    label: "Total Saved",
                    icon: "dollarsign.circle.fill",
                    color: FloatColors.success
                )
            }
            HStack(spacing: FloatSpacing.sm) {
                analyticsStatCard(
                    value: "\(stats.thisMonthRedemptions)",
                    label: "This Month",
                    icon: "calendar",
                    color: FloatColors.accent
                )
                analyticsStatCard(
                    value: "$\(String(format: "%.0f", stats.thisMonthSaved))",
                    label: "Saved This Month",
                    icon: "chart.line.uptrend.xyaxis",
                    color: FloatColors.drinkColor
                )
            }
        }
    }

    @ViewBuilder
    private func analyticsStatCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: FloatSpacing.xs) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
                Spacer()
            }
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(FloatColors.adaptiveTextPrimary)
            Text(label)
                .font(FloatFont.caption())
                .foregroundStyle(FloatColors.adaptiveTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(FloatSpacing.md)
        .background(FloatColors.adaptiveCardBackground)
        .cornerRadius(16)
    }

    // MARK: Streak Card

    @ViewBuilder
    private func streakCard(_ stats: RedemptionStats) -> some View {
        HStack(spacing: FloatSpacing.md) {
            Text("🔥")
                .font(.system(size: 36))
            VStack(alignment: .leading, spacing: FloatSpacing.xs) {
                HStack(spacing: FloatSpacing.xs) {
                    Text("\(stats.streakDays)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(FloatColors.warning)
                    Text("day streak")
                        .font(FloatFont.headline())
                        .foregroundStyle(FloatColors.adaptiveTextPrimary)
                }
                Text("Keep redeeming to maintain your streak!")
                    .font(FloatFont.caption())
                    .foregroundStyle(FloatColors.adaptiveTextSecondary)
            }
            Spacer()
        }
        .padding(FloatSpacing.md)
        .background(FloatColors.warning.opacity(0.12))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(FloatColors.warning.opacity(0.3), lineWidth: 1))
    }

    // MARK: Weekly Chart

    @ViewBuilder
    private func weeklyChart(_ stats: RedemptionStats) -> some View {
        VStack(alignment: .leading, spacing: FloatSpacing.md) {
            Text("Weekly Activity")
                .font(FloatFont.headline())
                .foregroundStyle(FloatColors.adaptiveTextPrimary)

            Chart(stats.weeklyData) { point in
                BarMark(
                    x: .value("Week", point.week),
                    y: .value("Redemptions", point.count)
                )
                .foregroundStyle(FloatColors.primary.gradient)
                .cornerRadius(4)
            }
            .frame(height: 160)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(FloatColors.adaptiveTextSecondary)
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(FloatColors.adaptiveTextSecondary)
                    AxisGridLine()
                        .foregroundStyle(FloatColors.adaptiveSeparator)
                }
            }
        }
        .padding(FloatSpacing.md)
        .background(FloatColors.adaptiveCardBackground)
        .cornerRadius(16)
    }

    // MARK: Category Breakdown

    @ViewBuilder
    private func categoryBreakdown(_ stats: RedemptionStats) -> some View {
        VStack(alignment: .leading, spacing: FloatSpacing.md) {
            Text("By Category")
                .font(FloatFont.headline())
                .foregroundStyle(FloatColors.adaptiveTextPrimary)

            Chart(stats.categoryBreakdown) { item in
                SectorMark(
                    angle: .value("Count", item.count),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(item.color)
                .cornerRadius(4)
            }
            .frame(height: 160)

            // Legend
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: FloatSpacing.sm) {
                ForEach(stats.categoryBreakdown) { item in
                    HStack(spacing: FloatSpacing.xs) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 10, height: 10)
                        Text(item.category)
                            .font(FloatFont.caption())
                            .foregroundStyle(FloatColors.adaptiveTextSecondary)
                        Spacer()
                        Text("\(item.count)")
                            .font(FloatFont.caption(.semibold))
                            .foregroundStyle(FloatColors.adaptiveTextPrimary)
                    }
                }
            }
        }
        .padding(FloatSpacing.md)
        .background(FloatColors.adaptiveCardBackground)
        .cornerRadius(16)
    }

    // MARK: Top Venues

    @ViewBuilder
    private func topVenues(_ stats: RedemptionStats) -> some View {
        VStack(alignment: .leading, spacing: FloatSpacing.md) {
            Text("Top Venues")
                .font(FloatFont.headline())
                .foregroundStyle(FloatColors.adaptiveTextPrimary)

            ForEach(Array(stats.topVenues.enumerated()), id: \.element.id) { index, venue in
                HStack(spacing: FloatSpacing.md) {
                    Text("\(index + 1)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(index == 0 ? FloatColors.warning : FloatColors.adaptiveTextSecondary)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(venue.venueName)
                            .font(FloatFont.body(.semibold))
                            .foregroundStyle(FloatColors.adaptiveTextPrimary)
                        Text("\(venue.visits) visits")
                            .font(FloatFont.caption())
                            .foregroundStyle(FloatColors.adaptiveTextSecondary)
                    }

                    Spacer()

                    Text("$\(String(format: "%.0f", venue.savings))")
                        .font(FloatFont.caption(.semibold))
                        .foregroundStyle(FloatColors.success)
                }
                .padding(.vertical, FloatSpacing.xs)
                if index < stats.topVenues.count - 1 {
                    Divider().background(FloatColors.adaptiveSeparator)
                }
            }
        }
        .padding(FloatSpacing.md)
        .background(FloatColors.adaptiveCardBackground)
        .cornerRadius(16)
    }
}

#Preview {
    AnalyticsDashboardView()
        .preferredColorScheme(.dark)
}
