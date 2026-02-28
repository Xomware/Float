import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.dealPins) { pin in
                MapAnnotation(coordinate: pin.coordinate) {
                    DealPinView(pin: pin)
                        .onTapGesture { viewModel.selectPin(pin) }
                }
            }
            .ignoresSafeArea()
            
            if let selected = viewModel.selectedPin {
                DealBottomSheet(pin: selected)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .task { await viewModel.loadNearbyDeals() }
    }
}

struct DealPinView: View {
    let pin: DealPin
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle().fill(FloatColors.primary).frame(width: 36, height: 36)
                Image(systemName: "tag.fill").foregroundStyle(.white).font(.system(size: 16))
            }
            Image(systemName: "arrowtriangle.down.fill")
                .foregroundStyle(FloatColors.primary)
                .font(.system(size: 8))
                .offset(y: -4)
        }
    }
}

struct DealBottomSheet: View {
    let pin: DealPin
    var body: some View {
        FloatCard {
            VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                Text(pin.venueName).font(FloatFont.headline())
                Text(pin.dealTitle).font(FloatFont.body()).foregroundStyle(FloatColors.textSecondary)
                HStack {
                    FloatBadge(pin.category.uppercased(), color: FloatColors.drinkColor)
                    Spacer()
                    Text(pin.expiresAt.timeRemainingShort).font(FloatFont.caption()).foregroundStyle(pin.expiresAt.isExpiringSoon ? FloatColors.warning : FloatColors.textSecondary)
                }
            }
        }
        .padding(.horizontal, FloatSpacing.md)
        .padding(.bottom, FloatSpacing.xl)
    }
}
