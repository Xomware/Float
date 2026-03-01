// MapView.swift
// Float

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Map with deal pins
            Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.filteredPins) { pin in
                MapAnnotation(coordinate: pin.coordinate) {
                    DealPinView(pin: pin, isSelected: viewModel.selectedPin?.id == pin.id)
                        .onTapGesture { viewModel.selectPin(pin) }
                }
            }
            .ignoresSafeArea()
            
            // Top-right controls
            VStack(alignment: .trailing, spacing: FloatSpacing.sm) {
                HStack(spacing: FloatSpacing.sm) {
                    // Active Now toggle
                    Button(action: { viewModel.toggleActiveNowFilter() }) {
                        HStack(spacing: FloatSpacing.xs) {
                            Image(systemName: "clock.fill")
                            Text("Active Now")
                                .font(FloatFont.caption(.semibold))
                        }
                        .padding(.horizontal, FloatSpacing.sm)
                        .padding(.vertical, 6)
                        .background(viewModel.activeNowOnly ? FloatColors.primary : FloatColors.cardBackground)
                        .foregroundStyle(viewModel.activeNowOnly ? .white : FloatColors.textPrimary)
                        .cornerRadius(FloatSpacing.badgeRadius)
                    }
                    
                    Spacer()
                }
                .padding(FloatSpacing.md)
                
                Spacer()
            }
            .padding(.top, FloatSpacing.md)
            .padding(.trailing, FloatSpacing.md)
            
            // Bottom sheet with deal details
            if let selected = viewModel.selectedPin {
                DealBottomSheet(pin: selected, onDismiss: { viewModel.selectPin(selected) })
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .refreshable { await viewModel.refreshDeals() }
        .task { await viewModel.loadNearbyDeals() }
    }
}

struct DealPinView: View {
    let pin: DealPin
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(pin.categoryColor)
                    .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                
                Image(systemName: categoryIcon)
                    .foregroundStyle(.white)
                    .font(.system(size: isSelected ? 18 : 14))
            }
            
            Image(systemName: "arrowtriangle.down.fill")
                .foregroundStyle(pin.categoryColor)
                .font(.system(size: 8))
                .offset(y: -4)
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
    
    private var categoryIcon: String {
        switch pin.category.lowercased() {
        case "drink": return "wineglass.fill"
        case "food": return "fork.knife"
        case "both": return "cart.fill"
        case "flash": return "bolt.fill"
        default: return "tag.fill"
        }
    }
}

struct DealBottomSheet: View {
    let pin: DealPin
    let onDismiss: () -> Void
    @State private var showDetail = false
    
    var body: some View {
        ZStack(alignment: .top) {
            // Tap-to-dismiss background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }
            
            FloatCard {
                VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                    // Handle bar
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(FloatColors.textSecondary.opacity(0.3))
                        .frame(width: 40, height: 5)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, FloatSpacing.sm)
                    
                    // Deal info
                    VStack(alignment: .leading, spacing: FloatSpacing.xs) {
                        Text(pin.venueName)
                            .font(FloatFont.headline())
                        
                        Text(pin.dealTitle)
                            .font(FloatFont.body())
                            .foregroundStyle(FloatColors.textSecondary)
                            .lineLimit(2)
                        
                        // Category badge and timer
                        HStack(spacing: FloatSpacing.sm) {
                            FloatBadge(pin.category.uppercased(), color: pin.categoryColor)
                            Spacer()
                            Text(pin.expiresAt.timeRemainingShort)
                                .font(FloatFont.caption(.semibold))
                                .foregroundStyle(pin.expiresAt.isExpiringSoon ? FloatColors.warning : FloatColors.textSecondary)
                        }
                    }
                    .padding(.bottom, FloatSpacing.sm)
                    
                    // Get Deal CTA
                    NavigationLink(destination: DealDetailView(deal: pin.deal)) {
                        FloatButton("Get Deal", icon: "sparkles", style: .primary) {
                            showDetail = true
                        }
                    }
                }
            }
            .padding(.horizontal, FloatSpacing.md)
            .padding(.top, FloatSpacing.md)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
