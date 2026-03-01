// ErrorStateView.swift
// Float

import SwiftUI

// MARK: - Error State View
public struct ErrorStateView: View {
    let title: String
    let message: String
    let retryLabel: String
    let onRetry: () -> Void

    @State private var appeared = false
    @State private var isRetrying = false

    public init(
        title: String = "Something Went Wrong",
        message: String,
        retryLabel: String = "Try Again",
        onRetry: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.retryLabel = retryLabel
        self.onRetry = onRetry
    }

    public var body: some View {
        VStack(spacing: FloatSpacing.lg) {
            Spacer()

            // Error icon
            ZStack {
                Circle()
                    .fill(FloatColors.error.opacity(0.12))
                    .frame(width: 100, height: 100)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(FloatColors.error)
                    .symbolRenderingMode(.hierarchical)
                    .rotationEffect(.degrees(appeared ? 0 : -15))
            }
            .scaleEffect(appeared ? 1 : 0.6)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.05), value: appeared)

            // Text
            VStack(spacing: FloatSpacing.xs) {
                Text(title)
                    .font(FloatFont.headline())
                    .foregroundStyle(FloatColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(FloatFont.body())
                    .foregroundStyle(FloatColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, FloatSpacing.xl)
            }
            .offset(y: appeared ? 0 : 10)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.1), value: appeared)

            // Retry button
            Button(action: {
                isRetrying = true
                onRetry()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isRetrying = false
                }
            }) {
                HStack(spacing: FloatSpacing.sm) {
                    if isRetrying {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: FloatColors.background))
                            .scaleEffect(0.9)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    Text(isRetrying ? "Retrying…" : retryLabel)
                        .font(FloatFont.callout(.semibold))
                }
                .foregroundStyle(FloatColors.background)
                .padding(.horizontal, FloatSpacing.xl)
                .padding(.vertical, FloatSpacing.sm)
                .background(isRetrying ? FloatColors.primary.opacity(0.7) : FloatColors.primary)
                .clipShape(Capsule())
                .animation(.easeInOut(duration: 0.2), value: isRetrying)
            }
            .disabled(isRetrying)
            .offset(y: appeared ? 0 : 10)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.17), value: appeared)
            .accessibilityLabel(retryLabel)
            .accessibilityHint("Retries the failed request")

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .onAppear { appeared = true }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
    }
}

// MARK: - Inline Error Banner
public struct ErrorBannerView: View {
    let message: String
    var onDismiss: (() -> Void)?

    public init(message: String, onDismiss: (() -> Void)? = nil) {
        self.message = message
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(spacing: FloatSpacing.sm) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(FloatColors.error)
                .font(.system(size: 16))
                .accessibilityHidden(true)

            Text(message)
                .font(FloatFont.caption(.medium))
                .foregroundStyle(FloatColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            if let dismiss = onDismiss {
                Button(action: dismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(FloatColors.textSecondary)
                }
                .accessibilityLabel("Dismiss error")
            }
        }
        .padding(FloatSpacing.sm)
        .background(FloatColors.error.opacity(0.14))
        .overlay(
            RoundedRectangle(cornerRadius: FloatSpacing.xs)
                .stroke(FloatColors.error.opacity(0.35), lineWidth: 1)
        )
        .cornerRadius(FloatSpacing.xs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(message)")
        .accessibilityAddTraits(.isStaticText)
    }
}

// MARK: - Network Error Helpers
public extension ErrorStateView {
    static func networkError(onRetry: @escaping () -> Void) -> ErrorStateView {
        ErrorStateView(
            title: "Connection Error",
            message: "Couldn't reach Float's servers. Check your internet connection and try again.",
            retryLabel: "Retry",
            onRetry: onRetry
        )
    }

    static func loadError(what: String = "deals", onRetry: @escaping () -> Void) -> ErrorStateView {
        ErrorStateView(
            title: "Couldn't Load \(what.capitalized)",
            message: "An error occurred while fetching \(what). Our team has been notified.",
            retryLabel: "Try Again",
            onRetry: onRetry
        )
    }
}
