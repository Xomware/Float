// VenueProfileView.swift
// Float

import SwiftUI

struct VenueProfileView: View {
    let venueId: UUID
    let venueName: String
    @State private var isSaved = false
    @State private var venue: Venue?
    @State private var venueDeals: [Deal] = []
    @State private var isLoading = false
    @State private var venuePhotos: [VenuePhoto] = []
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            FloatColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Photo gallery hero section
                ZStack(alignment: .topLeading) {
                    VenuePhotoGalleryView(photos: venuePhotos)
                        .clipShape(RoundedRectangle(cornerRadius: FloatSpacing.cardRadius))
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(FloatColors.textPrimary)
                            .padding(FloatSpacing.md)
                            .background(FloatColors.cardBackground.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .padding(FloatSpacing.md)
                }
                .padding(FloatSpacing.md)
                
                // Venue info
                ScrollView {
                    VStack(alignment: .leading, spacing: FloatSpacing.lg) {
                        // Header
                        VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                            HStack(alignment: .top, spacing: FloatSpacing.sm) {
                                VStack(alignment: .leading, spacing: FloatSpacing.xs) {
                                    Text(venueName)
                                        .font(FloatFont.title2())
                                    
                                    if let venue = venue {
                                        HStack(spacing: FloatSpacing.xs) {
                                            Image(systemName: "mappin.and.ellipse")
                                                .font(.system(size: 12))
                                            
                                            Text(venue.address ?? "Address not available")
                                                .font(FloatFont.caption())
                                                .foregroundStyle(FloatColors.textSecondary)
                                                .lineLimit(2)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: { isSaved.toggle() }) {
                                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                        .font(.system(size: 16))
                                        .foregroundStyle(isSaved ? FloatColors.primary : FloatColors.textSecondary)
                                }
                            }
                        }
                        .padding(FloatSpacing.md)
                        
                        // Status badge
                        if let venue = venue {
                            HStack(spacing: FloatSpacing.sm) {
                                Circle()
                                    .fill(venue.isOpenNow ? FloatColors.success : FloatColors.error)
                                    .frame(width: 8, height: 8)
                                
                                Text(venue.isOpenNow ? "Open Now" : "Closed")
                                    .font(FloatFont.caption(.semibold))
                                
                                if let closingTime = venue.closingTime {
                                    Text("Closes at \(closingTime)")
                                        .font(FloatFont.caption())
                                        .foregroundStyle(FloatColors.textSecondary)
                                }
                                
                                Spacer()
                            }
                            .padding(FloatSpacing.md)
                            .background(FloatColors.cardBackground)
                            .cornerRadius(FloatSpacing.cardRadius)
                            .padding(.horizontal, FloatSpacing.md)
                        }
                        
                        // Contact info
                        if let venue = venue {
                            VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                                if let phone = venue.phone {
                                    HStack(spacing: FloatSpacing.md) {
                                        Image(systemName: "phone.fill")
                                            .font(.system(size: 16))
                                            .foregroundStyle(FloatColors.primary)
                                            .frame(width: 32)
                                        
                                        Button(action: { /* Call action */ }) {
                                            Text(phone)
                                                .font(FloatFont.body())
                                                .foregroundStyle(FloatColors.textPrimary)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(FloatSpacing.md)
                                    .background(FloatColors.cardBackground)
                                    .cornerRadius(FloatSpacing.badgeRadius)
                                }
                                
                                if let website = venue.website {
                                    HStack(spacing: FloatSpacing.md) {
                                        Image(systemName: "globe")
                                            .font(.system(size: 16))
                                            .foregroundStyle(FloatColors.primary)
                                            .frame(width: 32)
                                        
                                        Button(action: { /* Open website */ }) {
                                            Text(website)
                                                .font(FloatFont.body())
                                                .foregroundStyle(FloatColors.primary)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(FloatSpacing.md)
                                    .background(FloatColors.cardBackground)
                                    .cornerRadius(FloatSpacing.badgeRadius)
                                }
                            }
                            .padding(.horizontal, FloatSpacing.md)
                        }
                        
                        // Deals at this venue
                        VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                            HStack {
                                Text("\(venueDeals.count) Active Deals")
                                    .font(FloatFont.headline())
                                
                                Spacer()
                            }
                            
                            if venueDeals.isEmpty {
                                Text("No active deals at this venue")
                                    .font(FloatFont.body())
                                    .foregroundStyle(FloatColors.textSecondary)
                                    .padding(FloatSpacing.md)
                                    .background(FloatColors.cardBackground)
                                    .cornerRadius(FloatSpacing.cardRadius)
                            } else {
                                VStack(spacing: FloatSpacing.sm) {
                                    ForEach(venueDeals) { deal in
                                        NavigationLink(destination: DealDetailView(deal: deal)) {
                                            DealCardView(deal: deal)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, FloatSpacing.md)
                        
                        Spacer()
                            .frame(height: FloatSpacing.lg)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadVenueData()
            await loadVenuePhotos()
        }
    }
    
    private func loadVenueData() async {
        isLoading = true
        defer { isLoading = false }
        
        // Mock venue data
        venue = Venue(
            id: venueId,
            name: venueName,
            address: "123 Main Street, Downtown",
            phone: "(555) 123-4567",
            website: "venue.example.com",
            hours: "Mon-Sun: 10am - 11pm",
            isOpenNow: true,
            closingTime: "11:00 PM"
        )
        
        // Mock venue deals
        venueDeals = [
            Deal(
                id: UUID(),
                title: "Happy Hour Special",
                description: "All drinks 50% off",
                category: "drink",
                venueId: venueId,
                venueName: venueName,
                expiresAt: Date().addingTimeInterval(3600),
                startsAt: Date(),
                discountType: "percentage",
                discountValue: 50,
                terms: "Valid 4pm-7pm daily",
                distanceFromUser: 500
            ),
            Deal(
                id: UUID(),
                title: "Appetizer Platter",
                description: "Buy one appetizer, get one free",
                category: "food",
                venueId: venueId,
                venueName: venueName,
                expiresAt: Date().addingTimeInterval(7200),
                startsAt: Date(),
                discountType: "bogo",
                discountValue: 1,
                terms: "Valid until end of day",
                distanceFromUser: 500
            )
        ]
    }

    private func loadVenuePhotos() async {
        do {
            venuePhotos = try await PhotoService.shared.fetchVenuePhotos(venueId: venueId)
        } catch {
            venuePhotos = []
        }
    }
}
