import SwiftUI

struct VenuePhotoGalleryView: View {
    let photos: [VenuePhoto]
    @State private var currentIndex = 0
    @State private var magnifyScale: CGFloat = 1.0
    @State private var lastMagnifyScale: CGFloat = 1.0

    var body: some View {
        if photos.isEmpty {
            placeholderView
        } else {
            galleryView
        }
    }

    // MARK: - Gallery

    private var galleryView: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $currentIndex) {
                ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                    photoPage(photo)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .frame(height: 260)

            // Photo count badge
            photoBadge
        }
    }

    private func photoPage(_ photo: VenuePhoto) -> some View {
        AsyncImage(url: URL(string: photo.url)) { phase in
            switch phase {
            case .empty:
                skeletonPlaceholder
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 260)
                    .clipped()
                    .scaleEffect(magnifyScale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                magnifyScale = lastMagnifyScale * value
                            }
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.3)) {
                                    magnifyScale = max(1.0, min(magnifyScale, 3.0))
                                    lastMagnifyScale = magnifyScale
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.spring(response: 0.3)) {
                            magnifyScale = magnifyScale > 1.0 ? 1.0 : 2.0
                            lastMagnifyScale = magnifyScale
                        }
                    }
            case .failure:
                errorPlaceholder
            @unknown default:
                skeletonPlaceholder
            }
        }
    }

    private var photoBadge: some View {
        Text("\(currentIndex + 1) / \(photos.count)")
            .font(FloatFont.caption2(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, FloatSpacing.sm)
            .padding(.vertical, FloatSpacing.xs)
            .background(.black.opacity(0.6))
            .clipShape(Capsule())
            .padding(FloatSpacing.md)
    }

    // MARK: - Placeholders

    private var placeholderView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: FloatSpacing.cardRadius)
                .fill(FloatColors.cardBackground)
                .frame(height: 200)

            Image(systemName: "building.2.fill")
                .font(.system(size: 80))
                .foregroundStyle(FloatColors.primary.opacity(0.3))
        }
    }

    private var skeletonPlaceholder: some View {
        Rectangle()
            .fill(FloatColors.cardBackground)
            .frame(height: 260)
            .overlay {
                ProgressView()
                    .tint(FloatColors.primary)
            }
    }

    private var errorPlaceholder: some View {
        Rectangle()
            .fill(FloatColors.cardBackground)
            .frame(height: 260)
            .overlay {
                Image(systemName: "photo.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(FloatColors.textSecondary.opacity(0.5))
            }
    }
}
