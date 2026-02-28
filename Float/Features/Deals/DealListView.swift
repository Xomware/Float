import SwiftUI

struct DealListView: View {
    @StateObject private var viewModel = DealViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: FloatSpacing.sm) {
                    ForEach(viewModel.deals) { deal in
                        NavigationLink(destination: DealDetailView(deal: deal)) {
                            DealCardView(deal: deal)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(FloatSpacing.md)
            }
            .floatScreenBackground()
            .navigationTitle("Active Deals")
            .navigationBarTitleDisplayMode(.large)
            .refreshable { await viewModel.loadDeals() }
        }
        .task { await viewModel.loadDeals() }
    }
}

struct DealDetailView: View {
    let deal: Deal
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FloatSpacing.lg) {
                Text(deal.title).font(FloatFont.title())
                Text(deal.description ?? "").foregroundStyle(FloatColors.textSecondary)
            }
            .padding(FloatSpacing.md)
        }
        .floatScreenBackground()
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SearchView: View {
    @State private var query = ""
    var body: some View {
        NavigationStack {
            Text("Search coming soon").foregroundStyle(FloatColors.textSecondary)
                .floatScreenBackground()
                .navigationTitle("Search")
                .searchable(text: $query)
        }
    }
}
