import SwiftUI

/// Post-redemption rating prompt shown as a modal sheet
struct RatingPromptView: View {
    @ObservedObject var viewModel: DealRatingViewModel
    let userId: UUID
    let dealTitle: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                FloatColors.background.ignoresSafeArea()

                VStack(spacing: FloatSpacing.lg) {
                    if viewModel.isSubmitted {
                        successContent
                    } else {
                        ratingContent
                    }
                }
                .padding(FloatSpacing.lg)
            }
            .navigationTitle("Rate This Deal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") { dismiss() }
                        .foregroundStyle(FloatColors.textSecondary)
                }
            }
        }
    }

    // MARK: - Rating Content

    private var ratingContent: some View {
        VStack(spacing: FloatSpacing.lg) {
            // Deal title
            Text(dealTitle)
                .font(FloatFont.headline())
                .foregroundStyle(FloatColors.textPrimary)
                .multilineTextAlignment(.center)

            Text("How was this deal?")
                .font(FloatFont.body())
                .foregroundStyle(FloatColors.textSecondary)

            // Star rating
            HStack(spacing: FloatSpacing.md) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            viewModel.selectedRating = star
                        }
                    } label: {
                        Image(systemName: star <= viewModel.selectedRating ? "star.fill" : "star")
                            .font(.system(size: 36))
                            .foregroundStyle(
                                star <= viewModel.selectedRating
                                    ? FloatColors.warning
                                    : FloatColors.textSecondary.opacity(0.4)
                            )
                            .scaleEffect(star <= viewModel.selectedRating ? 1.1 : 1.0)
                    }
                    .accessibilityLabel("\(star) star\(star == 1 ? "" : "s")")
                }
            }
            .padding(.vertical, FloatSpacing.md)

            // Optional review
            VStack(alignment: .leading, spacing: FloatSpacing.xs) {
                Text("Review (optional)")
                    .font(FloatFont.caption())
                    .foregroundStyle(FloatColors.textSecondary)

                TextEditor(text: $viewModel.reviewText)
                    .font(FloatFont.body())
                    .frame(minHeight: 80, maxHeight: 120)
                    .padding(FloatSpacing.sm)
                    .background(FloatColors.cardBackground)
                    .cornerRadius(FloatSpacing.cardRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: FloatSpacing.cardRadius)
                            .stroke(
                                viewModel.isReviewValid
                                    ? FloatColors.textSecondary.opacity(0.2)
                                    : Color.red,
                                lineWidth: 1
                            )
                    )

                HStack {
                    if !viewModel.isReviewValid {
                        Text("Max 200 characters")
                            .font(FloatFont.caption2())
                            .foregroundStyle(.red)
                    }
                    Spacer()
                    Text("\(viewModel.reviewCharCount)/200")
                        .font(FloatFont.caption2())
                        .foregroundStyle(
                            viewModel.isReviewValid
                                ? FloatColors.textSecondary
                                : .red
                        )
                }
            }

            // Error
            if let error = viewModel.error {
                Text(error)
                    .font(FloatFont.caption())
                    .foregroundStyle(.red)
            }

            Spacer()

            // Submit button
            FloatButton(
                viewModel.isSubmitting ? "Submitting..." : "Submit Rating",
                icon: "star.fill",
                style: .primary
            ) {
                Task {
                    await viewModel.submitRating(userId: userId)
                }
            }
            .disabled(!viewModel.canSubmit)
            .opacity(viewModel.canSubmit ? 1.0 : 0.5)
        }
    }

    // MARK: - Success Content

    private var successContent: some View {
        VStack(spacing: FloatSpacing.lg) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(FloatColors.success)

            Text("Thanks for your feedback!")
                .font(FloatFont.title2())
                .foregroundStyle(FloatColors.textPrimary)

            Text("Your rating helps others find great deals.")
                .font(FloatFont.body())
                .foregroundStyle(FloatColors.textSecondary)
                .multilineTextAlignment(.center)

            Spacer()

            FloatButton("Done", style: .primary) {
                dismiss()
            }
        }
    }
}
