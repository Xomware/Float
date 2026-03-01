import XCTest
@testable import Float

@MainActor
final class RatingViewModelTests: XCTestCase {

    func testInitialState() {
        let vm = DealRatingViewModel(dealId: UUID())
        XCTAssertEqual(vm.selectedRating, 0)
        XCTAssertEqual(vm.reviewText, "")
        XCTAssertFalse(vm.isSubmitting)
        XCTAssertFalse(vm.isSubmitted)
        XCTAssertNil(vm.error)
        XCTAssertEqual(vm.averageRating, 0.0)
        XCTAssertEqual(vm.reviewCount, 0)
        XCTAssertFalse(vm.hasLoaded)
    }

    func testCanSubmitRequiresRating() {
        let vm = DealRatingViewModel(dealId: UUID())
        XCTAssertFalse(vm.canSubmit, "Should not submit with 0 stars")

        vm.selectedRating = 3
        XCTAssertTrue(vm.canSubmit, "Should submit with valid rating")
    }

    func testCanSubmitFailsForInvalidRating() {
        let vm = DealRatingViewModel(dealId: UUID())
        vm.selectedRating = 6
        XCTAssertFalse(vm.canSubmit)
    }

    func testReviewCharCount() {
        let vm = DealRatingViewModel(dealId: UUID())
        vm.reviewText = "Great deal!"
        XCTAssertEqual(vm.reviewCharCount, 11)
    }

    func testReviewValidation() {
        let vm = DealRatingViewModel(dealId: UUID())
        vm.reviewText = String(repeating: "a", count: 200)
        XCTAssertTrue(vm.isReviewValid)

        vm.reviewText = String(repeating: "a", count: 201)
        XCTAssertFalse(vm.isReviewValid)
    }

    func testCanSubmitFailsWhenReviewTooLong() {
        let vm = DealRatingViewModel(dealId: UUID())
        vm.selectedRating = 4
        vm.reviewText = String(repeating: "x", count: 201)
        XCTAssertFalse(vm.canSubmit, "Should not submit with review > 200 chars")
    }

    func testCanSubmitFalseWhileSubmitting() {
        let vm = DealRatingViewModel(dealId: UUID())
        vm.selectedRating = 5
        vm.isSubmitting = true
        XCTAssertFalse(vm.canSubmit)
    }
}
