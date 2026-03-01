import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.xomware.float", category: "DealRating")

@MainActor
class DealRatingViewModel: ObservableObject {
    @Published var selectedRating: Int = 0
    @Published var reviewText: String = ""
    @Published var isSubmitting = false
    @Published var isSubmitted = false
    @Published var error: String?

    // Display state
    @Published var averageRating: Double = 0.0
    @Published var reviewCount: Int = 0
    @Published var hasLoaded = false

    let dealId: UUID
    private let ratingService: RatingService

    init(dealId: UUID, ratingService: RatingService = .shared) {
        self.dealId = dealId
        self.ratingService = ratingService
    }

    var reviewCharCount: Int { reviewText.count }
    var isReviewValid: Bool { reviewText.count <= 200 }
    var canSubmit: Bool { selectedRating >= 1 && selectedRating <= 5 && !isSubmitting && isReviewValid }

    // MARK: - Actions

    func submitRating(userId: UUID) async {
        guard canSubmit else { return }
        isSubmitting = true
        error = nil

        do {
            let review = reviewText.isEmpty ? nil : reviewText
            try await ratingService.submitRating(
                dealId: dealId,
                userId: userId,
                rating: selectedRating,
                review: review
            )
            isSubmitted = true
            logger.info("Rating submitted: \(self.selectedRating) stars for deal \(self.dealId)")
            // Refresh average after submission
            await loadAverageRating()
        } catch {
            self.error = "Failed to submit rating. Please try again."
            logger.error("Submit rating error: \(error.localizedDescription)")
        }

        isSubmitting = false
    }

    func loadAverageRating() async {
        do {
            let (avg, count) = try await ratingService.fetchAverageRating(dealId: dealId)
            averageRating = avg
            reviewCount = count
            hasLoaded = true
        } catch {
            logger.error("Load rating error: \(error.localizedDescription)")
        }
    }
}
